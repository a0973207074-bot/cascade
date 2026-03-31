---
name: computer-vision
description: "電腦視覺開發實踐。圖像處理、物體偵測、3D視覺、SLAM。專注於機器人感知系統。"
risk: medium
source: custom
date_added: "2026-03-31"
---

# Computer Vision

> 機器人電腦視覺開發指南。從基礎圖像處理到3D感知的完整技術棧。

## When to Use
開發機器人感知系統、視覺導航、物體識別、3D重建時使用此技能。

---

## 基礎圖像處理

### 1. OpenCV核心操作
```python
import cv2
import numpy as np

class ImageProcessor:
    def __init__(self):
        self.camera_matrix = None
        self.dist_coeffs = None
    
    def preprocess_image(self, image):
        """圖像預處理"""
        # 降噪
        denoised = cv2.fastNlMeansDenoisingColored(image)
        
        # 白平衡
        balanced = self.white_balance(denoised)
        
        # 銳化
        sharpened = self.sharpen(balanced)
        
        return sharpened
    
    def white_balance(self, image):
        """自動白平衡"""
        result = cv2.cvtColor(image, cv2.COLOR_BGR2LAB)
        avg_a = np.average(result[:, :, 1])
        avg_b = np.average(result[:, :, 2])
        result[:, :, 1] = result[:, :, 1] - ((avg_a - 128) * (result[:, :, 0] / 255.0) * 1.1)
        result[:, :, 2] = result[:, :, 2] - ((avg_b - 128) * (result[:, :, 0] / 255.0) * 1.1)
        return cv2.cvtColor(result, cv2.COLOR_LAB2BGR)
```

### 2. 相機標定
```python
class CameraCalibrator:
    def __init__(self, chessboard_size=(9, 6)):
        self.chessboard_size = chessboard_size
        self.criteria = (cv2.TERM_CRITERIA_EPS + cv2.TERM_CRITERIA_MAX_ITER, 30, 0.001)
        self.obj_points = []
        self.img_points = []
    
    def calibrate_from_images(self, images):
        """從圖像集進行標定"""
        objp = np.zeros((self.chessboard_size[0] * self.chessboard_size[1], 3), np.float32)
        objp[:, :2] = np.mgrid[0:self.chessboard_size[0], 0:self.chessboard_size[1]].T.reshape(-1, 2)
        
        for image in images:
            gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
            ret, corners = cv2.findChessboardCorners(gray, self.chessboard_size, None)
            
            if ret:
                self.obj_points.append(objp)
                self.img_points.append(corners)
        
        # 執行標定
        ret, mtx, dist, rvecs, tvecs = cv2.calibrateCamera(
            self.obj_points, self.img_points, gray.shape[::-1], None, None
        )
        
        return ret, mtx, dist, rvecs, tvecs
```

---

## 物體偵測與識別

### 1. YOLOv8整合
```python
from ultralytics import YOLO
import torch

class ObjectDetector:
    def __init__(self, model_path='yolov8n.pt'):
        self.model = YOLO(model_path)
        self.device = 'cuda' if torch.cuda.is_available() else 'cpu'
        self.model.to(self.device)
    
    def detect_objects(self, image, conf_threshold=0.5):
        """物體偵測"""
        results = self.model(image, conf=conf_threshold)
        
        detections = []
        for result in results:
            boxes = result.boxes
            for box in boxes:
                # 提取偵測資訊
                x1, y1, x2, y2 = box.xyxy[0].cpu().numpy()
                conf = box.conf[0].cpu().numpy()
                cls = box.cls[0].cpu().numpy()
                
                detections.append({
                    'bbox': [int(x1), int(y1), int(x2), int(y2)],
                    'confidence': float(conf),
                    'class_id': int(cls),
                    'class_name': self.model.names[int(cls)]
                })
        
        return detections
    
    def track_objects(self, detections, previous_detections):
        """簡單的物體追蹤"""
        if not previous_detections:
            return detections
        
        # 基於IoU的追蹤
        tracked = []
        for det in detections:
            best_match = None
            best_iou = 0
            
            for prev_det in previous_detections:
                iou = self.calculate_iou(det['bbox'], prev_det['bbox'])
                if iou > best_iou and iou > 0.3:
                    best_iou = iou
                    best_match = prev_det
            
            if best_match and det['class_name'] == best_match['class_name']:
                det['track_id'] = best_match.get('track_id', len(tracked))
            else:
                det['track_id'] = len(tracked)
            
            tracked.append(det)
        
        return tracked
```

### 2. 自定義訓練
```python
class CustomTrainer:
    def __init__(self, data_config):
        self.data_config = data_config
        self.model = YOLO('yolov8n.pt')
    
    def train_custom_model(self, epochs=100):
        """訓練自定義模型"""
        results = self.model.train(
            data=self.data_config,
            epochs=epochs,
            imgsz=640,
            batch=16,
            device='cuda' if torch.cuda.is_available() else 'cpu',
            project='custom_detection',
            name='g1_objects'
        )
        
        return results
```

---

## 3D視覺與深度感知

### 1. 立體視覺
```python
class StereoVision:
    def __init__(self, camera_matrix1, camera_matrix2, dist_coeffs1, dist_coeffs2, R, T):
        self.camera_matrix1 = camera_matrix1
        self.camera_matrix2 = camera_matrix2
        self.dist_coeffs1 = dist_coeffs1
        self.dist_coeffs2 = dist_coeffs2
        self.R = R
        self.T = T
        
        # 計算投影矩陣
        self.proj_matrix1 = np.hstack((camera_matrix1, np.zeros((3, 1))))
        self.proj_matrix2 = np.hstack((camera_matrix2, T))
    
    def compute_disparity(self, img1, img2):
        """計算視差圖"""
        # 轉換為灰階
        gray1 = cv2.cvtColor(img1, cv2.COLOR_BGR2GRAY)
        gray2 = cv2.cvtColor(img2, cv2.COLOR_BGR2GRAY)
        
        # 立體匹配
        stereo = cv2.StereoBM_create(numDisparities=64, blockSize=15)
        disparity = stereo.compute(gray1, gray2)
        
        return disparity
    
    def depth_from_disparity(self, disparity):
        """從視差計算深度"""
        # 焦距 (假設兩相機相同)
        f = self.camera_matrix1[0, 0]
        # 基線距離
        baseline = np.linalg.norm(self.T)
        
        # 深度計算
        depth = (f * baseline) / disparity
        depth[disparity <= 0] = 0  # 無效深度設為0
        
        return depth
```

### 2. 點雲處理
```python
import open3d as o3d

class PointCloudProcessor:
    def __init__(self):
        self.pcd = None
    
    def depth_to_pointcloud(self, depth_image, camera_matrix, color_image=None):
        """深度圖轉點雲"""
        height, width = depth_image.shape
        
        # 生成像素座標網格
        u, v = np.meshgrid(np.arange(width), np.arange(height))
        u = u.flatten()
        v = v.flatten()
        depth = depth_image.flatten()
        
        # 過濾無效深度
        valid = depth > 0
        u = u[valid]
        v = v[valid]
        depth = depth[valid]
        
        # 轉換為3D座標
        fx, fy = camera_matrix[0, 0], camera_matrix[1, 1]
        cx, cy = camera_matrix[0, 2], camera_matrix[1, 2]
        
        x = (u - cx) * depth / fx
        y = (v - cy) * depth / fy
        z = depth
        
        # 創建點雲
        points = np.column_stack((x, y, z))
        self.pcd = o3d.geometry.PointCloud()
        self.pcd.points = o3d.utility.Vector3dVector(points)
        
        # 添加顏色資訊
        if color_image is not None:
            colors = color_image.reshape(-1, 3)[valid] / 255.0
            self.pcd.colors = o3d.utility.Vector3dVector(colors)
        
        return self.pcd
    
    def filter_outliers(self, nb_neighbors=20, std_ratio=2.0):
        """離群點濾波"""
        if self.pcd is not None:
            self.pcd, _ = self.pcd.remove_statistical_outlier(
                nb_neighbors=nb_neighbors, std_ratio=std_ratio
            )
        return self.pcd
    
    def segment_plane(self, distance_threshold=0.01, ransac_n=3, num_iterations=1000):
        """平面分割"""
        if self.pcd is not None:
            plane_model, inliers = self.pcd.segment_plane(
                distance_threshold=distance_threshold,
                ransac_n=ransac_n,
                num_iterations=num_iterations
            )
            
            # 提取平面點雲
            plane_cloud = self.pcd.select_by_index(inliers)
            remaining_cloud = self.pcd.select_by_index(inliers, invert=True)
            
            return plane_model, plane_cloud, remaining_cloud
```

---

## SLAM系統

### 1. 視覺SLAM
```python
class VisualSLAM:
    def __init__(self, camera_matrix, dist_coeffs):
        self.camera_matrix = camera_matrix
        self.dist_coeffs = dist_coeffs
        self.orb = cv2.ORB_create(nfeatures=2000)
        self.matcher = cv2.BFMatcher(cv2.NORM_HAMMING, crossCheck=True)
        
        # 地圖點
        self.map_points = []
        self.keyframes = []
        
        # 位姿估計
        self.current_pose = np.eye(4)
    
    def process_frame(self, image):
        """處理單幀影像"""
        # 特徵提取
        keypoints, descriptors = self.orb.detectAndCompute(image, None)
        
        if len(self.keyframes) > 0:
            # 特徵匹配
            matches = self.matcher.match(descriptors, self.keyframes[-1]['descriptors'])
            
            if len(matches) > 50:
                # 位姿估計
                points_2d = np.array([keypoints[m.trainIdx].pt for m in matches])
                points_3d = self.get_corresponding_3d_points(matches)
                
                # PnP求解
                success, rvec, tvec = cv2.solvePnP(
                    points_3d, points_2d, self.camera_matrix, self.dist_coeffs
                )
                
                if success:
                    # 更新當前位姿
                    self.update_pose(rvec, tvec)
                    
                    # 三角化新地圖點
                    self.triangulate_points(keypoints, descriptors, matches)
        
        # 保存關鍵幀
        self.add_keyframe(image, keypoints, descriptors)
        
        return self.current_pose
    
    def triangulate_points(self, keypoints, descriptors, matches):
        """三角化新地圖點"""
        # 實現三角化邏輯
        pass
    
    def update_pose(self, rvec, tvec):
        """更新位姿"""
        R, _ = cv2.Rodrigues(rvec)
        T = tvec.reshape(3, 1)
        
        # 更新變換矩陣
        self.current_pose[:3, :3] = R
        self.current_pose[:3, 3] = T.flatten()
```

---

## 機器人視覺應用

### 1. 導航系統
```python
class VisionNavigation:
    def __init__(self):
        self.obstacle_detector = ObjectDetector('yolov8n.pt')
        self.path_planner = PathPlanner()
        self.slam = VisualSLAM()
    
    def navigate_to_target(self, current_image, target_position):
        """導航到目標位置"""
        # SLAM定位
        current_pose = self.slam.process_frame(current_image)
        
        # 障礙物偵測
        obstacles = self.obstacle_detector.detect_objects(current_image)
        
        # 路徑規劃
        path = self.path_planner.plan_path(current_pose[:3, 3], target_position, obstacles)
        
        return path
    
    def avoid_obstacles(self, obstacles, robot_position):
        """避障邏輯"""
        safe_distance = 1.0  # 安全距離 (米)
        avoidance_vector = np.zeros(3)
        
        for obstacle in obstacles:
            # 計算障礙物相對位置
            obstacle_pos = self.estimate_obstacle_position(obstacle)
            relative_pos = obstacle_pos - robot_position
            distance = np.linalg.norm(relative_pos)
            
            if distance < safe_distance:
                # 計算避障向量
                avoidance_vector -= (relative_pos / distance) * (safe_distance - distance)
        
        return avoidance_vector
```

### 2. 物體操作
```python
class ObjectManipulation:
    def __init__(self):
        self.detector = ObjectDetector('yolov8n.pt')
        self.pose_estimator = PoseEstimator()
        self.grasp_planner = GraspPlanner()
    
    def detect_and_grasp(self, image, depth_image):
        """偵測並抓取物體"""
        # 物體偵測
        objects = self.detector.detect_objects(image)
        
        graspable_objects = []
        for obj in objects:
            if obj['class_name'] in ['cup', 'bottle', 'box']:
                # 6D姿態估計
                pose = self.pose_estimator.estimate_pose(obj, depth_image)
                
                # 抓取規劃
                grasp = self.grasp_planner.plan_grasp(pose)
                
                graspable_objects.append({
                    'object': obj,
                    'pose': pose,
                    'grasp': grasp
                })
        
        return graspable_objects
```

---

## 效能優化

### 1. GPU加速
```python
import cupy as cp

class GPUImageProcessor:
    def __init__(self):
        self.gpu_available = cp.is_available()
    
    def preprocess_gpu(self, image):
        """GPU圖像預處理"""
        if not self.gpu_available:
            return self.preprocess_cpu(image)
        
        # 轉移到GPU
        gpu_image = cp.asarray(image)
        
        # GPU處理
        gpu_gray = cv2.cvtColor(gpu_image.get(), cv2.COLOR_BGR2GRAY)
        
        return gpu_gray.get()
```

### 2. 多執行緒處理
```python
import threading
from queue import Queue

class MultiThreadVision:
    def __init__(self):
        self.frame_queue = Queue(maxsize=10)
        self.result_queue = Queue(maxsize=10)
        self.running = False
    
    def start_processing(self):
        """啟動多執行緒處理"""
        self.running = True
        
        # 處理執行緒
        self.process_thread = threading.Thread(target=self._process_frames)
        self.process_thread.start()
    
    def _process_frames(self):
        """處理幀的執行緒"""
        while self.running:
            if not self.frame_queue.empty():
                frame = self.frame_queue.get()
                result = self.process_single_frame(frame)
                self.result_queue.put(result)
```

---

## 最佳實踐

### 1. 系統整合
```python
class IntegratedVisionSystem:
    def __init__(self):
        self.camera = Camera()
        self.detector = ObjectDetector()
        self.slam = VisualSLAM()
        self.navigator = VisionNavigation()
    
    def run_vision_pipeline(self):
        """完整視覺處理管線"""
        while True:
            # 獲取影像
            image = self.camera.get_image()
            
            # 並行處理
            detection_result = self.detector.detect_objects(image)
            pose_result = self.slam.process_frame(image)
            
            # 整合結果
            integrated_result = self.integrate_results(
                detection_result, pose_result
            )
            
            yield integrated_result
```

### 2. 錯誤處理
```python
class RobustVisionSystem:
    def __init__(self):
        self.fallback_detectors = [
            ObjectDetector('yolov8n.pt'),
            ObjectDetector('yolov8s.pt'),
            ObjectDetector('yolov8m.pt')
        ]
    
    def robust_detect(self, image):
        """強健的物體偵測"""
        for detector in self.fallback_detectors:
            try:
                results = detector.detect_objects(image)
                if len(results) > 0:
                    return results
            except Exception as e:
                print(f"Detector failed: {e}")
                continue
        
        return []
```
