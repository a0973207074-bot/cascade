---
name: ros2-development
description: "ROS 2 Humble 開發最佳實踐。節點設計、通訊模式、Launch系統、參數配置、除錯技巧。專為機器人系統設計。"
risk: low
source: custom
date_added: "2026-03-31"
---

# ROS 2 Development

> ROS 2 Humble 開發原則與最佳實踐。專注於穩定性、效能與可維護性。

## When to Use
使用此技能進行ROS 2系統開發，包括節點設計、通訊架構、Launch配置和系統除錯。

---

## 核心原則

### 1. 節點設計原則
- **單一職責**：每個節點只負責一個核心功能
- **狀態機設計**：使用生命週期管理節點狀態
- **異常處理**：完整的錯誤處理與恢復機制

### 2. 通訊模式選擇
```python
# Topic - 適合持續性數據流
self.publisher = self.create_publisher(Image, '/camera/image_raw', 10)

# Service - 適合請求-響應模式
self.service = self.create_service(SetBool, '/emergency_stop', self.stop_callback)

# Action - 適合長時間任務
self.action_server = ActionServer(self, MoveToPose, '/move_to_pose', self.execute_callback)

# Parameter - 適合配置參數
self.declare_parameter('update_rate', 30.0)
```

### 3. Launch系統設計
```python
# 可重複使用的Launch文件
def generate_launch_description():
    return LaunchDescription([
        Node(
            package='unitree_g1',
            executable='gait_controller',
            parameters=[{'use_sim_time': True}],
            remappings=[('/cmd_vel', '/g1/cmd_vel')]
        )
    ])
```

---

## 最佳實踐

### 節點命名規範
```python
# ✅ 好的命名
class G1GaitController(Node):
    def __init__(self):
        super().__init__('g1_gait_controller')
        
# ❌ 避免的命名  
class Controller(Node):  # 太過通用
class G1Controller(Node):  # 不夠具體
```

### QoS設定策略
```python
# 感測器數據 - 高頻率，允許丟失
sensor_qos = QoSProfile(
    reliability=QoSReliabilityPolicy.BEST_EFFORT,
    durability=QoSDurabilityPolicy.VOLATILE,
    depth=1
)

# 控制指令 - 可靠傳輸
control_qos = QoSProfile(
    reliability=QoSReliabilityPolicy.RELIABLE,
    durability=QoSDurabilityPolicy.VOLATILE,
    depth=10
)
```

### 參數管理
```python
class ConfigurableNode(Node):
    def __init__(self):
        super().__init__('configurable_node')
        
        # 宣告參數與預設值
        self.declare_parameter('update_rate', 30.0)
        self.declare_parameter('max_velocity', 2.0)
        self.declare_parameter('safety_limits', [1.0, 1.0, 0.5])
        
        # 參數變更回調
        self.add_on_set_parameters_callback(self.parameter_callback)
    
    def parameter_callback(self, params):
        # 參數驗證與更新邏輯
        return SetParametersResult(successful=True)
```

---

## 除錯技巧

### 1. 節點監控
```bash
# 查看節點狀態
ros2 node list
ros2 node info /g1_gait_controller

# 查看話題流量
ros2 topic hz /camera/image_raw
ros2 topic echo /joint_states
```

### 2. 系統監控
```bash
# 監控CPU/記憶體使用
ros2 run rqt_top rqt_top

# 查看節點圖
ros2 run rqt_graph rqt_graph
```

### 3. 日誌除錯
```python
# 設定日誌級別
import rclpy
from rclpy.logging import get_logger

logger = get_logger('g1_controller')
logger.info('System initialized')
logger.warning('High temperature detected')
logger.error('Motor communication failed')
```

---

## Unitree G1 特定模式

### 1. 硬體介面節點
```python
class UnitreeHardwareInterface(Node):
    def __init__(self):
        super().__init__('unitree_hardware_interface')
        
        # 聯合關節狀態發布器
        self.joint_state_pub = self.create_publisher(
            JointState, '/joint_states', 10
        )
        
        # 關節指令訂閱者
        self.joint_cmd_sub = self.create_subscription(
            JointTrajectory, '/joint_trajectory', 
            self.joint_callback, 10
        )
```

### 2. 安全監控節點
```python
class SafetyMonitor(Node):
    def __init__(self):
        super().__init__('safety_monitor')
        
        # 緊急停止發布器
        self.emergency_stop_pub = self.create_publisher(
            Bool, '/emergency_stop', 10
        )
        
        # 狀態監控定時器
        self.timer = self.create_timer(0.1, self.monitor_callback)
```

---

## 效能優化

### 1. 記憶體管理
```python
# 避免頻繁記憶體分配
class EfficientNode(Node):
    def __init__(self):
        super().__init__('efficient_node')
        
        # 預分配訊息物件
        self.joint_msg = JointState()
        self.joint_msg.name = [...]
        self.joint_msg.position = [0.0] * 12
```

### 2. 多執行緒處理
```python
from rclpy.executors import MultiThreadedExecutor

def main(args=None):
    rclpy.init(args=args)
    
    node = HighFrequencyNode()
    executor = MultiThreadedExecutor(num_threads=4)
    executor.add_node(node)
    
    try:
        executor.spin()
    finally:
        executor.shutdown()
        node.destroy_node()
```

---

## 測試策略

### 1. 單元測試
```python
import pytest
from unitree_g1.gait_controller import GaitController

def test_gait_controller_initialization():
    node = GaitController()
    assert node.get_parameter('update_rate').value == 50.0
```

### 2. 整合測試
```python
# launch_testing框架
import launch_testing
from launch import LaunchDescription

def test_system_integration():
    # 測試完整系統運行
    pass
```

---

## 常見問題與解決方案

### 1. 節點無法啟動
```bash
# 檢查ROS_DOMAIN_ID
echo $ROS_DOMAIN_ID

# 檢查網路設定
ros2 multicast receive
```

### 2. 通訊延遲
```python
# 使用shared memory傳輸
from rclpy.qos import QoSProfile
shared_memory_qos = QoSProfile(depth=10)
shared_memory_qos.reliability = QoSReliabilityPolicy.RELIABLE
```

### 3. 參數載入失敗
```yaml
# params.yaml
g1_gait_controller:
  ros__parameters:
    update_rate: 50.0
    max_velocity: 2.0
    safety_limits: [1.0, 1.0, 0.5]
```

---

## 開發工具推薦

- **rqt**：GUI工具集
- **rviz2**：3D可視化
- **ros2 bag**：數據記錄與回放
- **teleop_twist_keyboard**：鍵盤控制
- **robot_state_publisher**：機器人狀態可視化
