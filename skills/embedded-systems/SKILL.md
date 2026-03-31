---
name: embedded-systems
description: "嵌入式系統開發實踐。微控制器程式設計、實時作業系統、硬體介面、最佳化技巧。專注於機器人控制系統。"
risk: medium
source: custom
date_added: "2026-03-31"
---

# Embedded Systems

> 機器人嵌入式系統開發指南。從微控制器到實時控制的完整技術棧。

## When to Use
開發機器人底層控制、微控制器程式、實時系統、硬體驅動時使用此技能。

---

## 微控制器程式設計

### 1. STM32 HAL開發
```c
#include "stm32f4xx_hal.h"
#include <string.h>

// 機器人控制器結構體
typedef struct {
    TIM_HandleTypeDef htim_pwm;
    ADC_HandleTypeDef hadc_joint;
    UART_HandleTypeDef huart_comm;
    uint32_t joint_positions[12];
    uint32_t target_positions[12];
} RobotController_t;

// 初始化硬體
void RobotController_Init(RobotController_t* controller) {
    // PWM定時器初始化
    TIM_HandleTypeDef htim_pwm;
    htim_pwm.Instance = TIM2;
    htim_pwm.Init.Prescaler = 84 - 1;
    htim_pwm.Init.CounterMode = TIM_COUNTERMODE_UP;
    htim_pwm.Init.Period = 20000 - 1;  // 50Hz PWM
    HAL_TIM_PWM_Init(&htim_pwm);
    
    // ADC初始化
    ADC_HandleTypeDef hadc_joint;
    hadc_joint.Instance = ADC1;
    hadc_joint.Init.ClockPrescaler = ADC_CLOCK_SYNC_PCLK_DIV4;
    hadc_joint.Init.Resolution = ADC_RESOLUTION_12B;
    HAL_ADC_Init(&hadc_joint);
    
    // UART初始化
    UART_HandleTypeDef huart_comm;
    huart_comm.Instance = USART2;
    huart_comm.Init.BaudRate = 115200;
    huart_comm.Init.WordLength = UART_WORDLENGTH_8B;
    huart_comm.Init.StopBits = UART_STOPBITS_1;
    HAL_UART_Init(&huart_comm);
}

// 關節控制函數
void SetJointPosition(RobotController_t* controller, uint8_t joint_id, uint32_t position) {
    if (joint_id < 12) {
        controller->target_positions[joint_id] = position;
        
        // 設定PWM值
        uint32_t pwm_value = position;  // 0-20000對應0-100%占空比
        __HAL_TIM_SET_COMPARE(&controller->htim_pwm, joint_id, pwm_value);
    }
}

// 讀取關節位置
uint32_t GetJointPosition(RobotController_t* controller, uint8_t joint_id) {
    if (joint_id < 12) {
        // 啟動ADC轉換
        HAL_ADC_Start(&controller->hadc_joint);
        
        // 等待轉換完成
        if (HAL_ADC_PollForConversion(&controller->hadc_joint, 1000) == HAL_OK) {
            uint32_t adc_value = HAL_ADC_GetValue(&controller->hadc_joint);
            
            // 轉換為角度 (假設0-4095對應0-360度)
            controller->joint_positions[joint_id] = (adc_value * 360) / 4095;
            
            HAL_ADC_Stop(&controller->hadc_joint);
            return controller->joint_positions[joint_id];
        }
    }
    return 0;
}
```

### 2. 實時作業系統 (FreeRTOS)
```c
#include "FreeRTOS.h"
#include "task.h"
#include "queue.h"
#include "semphr.h"

// 任務優先級定義
#define MOTOR_CONTROL_PRIORITY    (tskIDLE_PRIORITY + 3)
#define SENSOR_READ_PRIORITY     (tskIDLE_PRIORITY + 2)
#define COMMUNICATION_PRIORITY   (tskIDLE_PRIORITY + 1)

// 任務控制塊
TaskHandle_t motor_control_task_handle;
TaskHandle_t sensor_read_task_handle;
TaskHandle_t communication_task_handle;

// 佇列和信號量
QueueHandle_t joint_command_queue;
SemaphoreHandle_t motor_mutex;

// 馬達控制任務
void MotorControlTask(void* parameters) {
    RobotController_t* controller = (RobotController_t*)parameters;
    JointCommand_t command;
    
    while (1) {
        // 等待關節指令
        if (xQueueReceive(joint_command_queue, &command, portMAX_DELAY) == pdTRUE) {
            // 取得馬達控制權
            if (xSemaphoreTake(motor_mutex, portMAX_DELAY) == pdTRUE) {
                // 執行關節控制
                SetJointPosition(controller, command.joint_id, command.position);
                
                // 釋放馬達控制權
                xSemaphoreGive(motor_mutex);
            }
        }
        
        // 任務延遲
        vTaskDelay(pdMS_TO_TICKS(10));
    }
}

// 感測器讀取任務
void SensorReadTask(void* parameters) {
    RobotController_t* controller = (RobotController_t*)parameters;
    SensorData_t sensor_data;
    
    while (1) {
        // 讀取所有關節位置
        for (uint8_t i = 0; i < 12; i++) {
            sensor_data.joint_positions[i] = GetJointPosition(controller, i);
        }
        
        // 讀取IMU數據
        sensor_data.imu_data = ReadIMU();
        
        // 發送感測器數據
        xQueueSend(sensor_data_queue, &sensor_data, 0);
        
        // 20Hz更新頻率
        vTaskDelay(pdMS_TO_TICKS(50));
    }
}

// 系統初始化
void SystemInit(void) {
    // 硬體初始化
    RobotController_Init(&g_robot_controller);
    
    // 創建佇列
    joint_command_queue = xQueueCreate(10, sizeof(JointCommand_t));
    sensor_data_queue = xQueueCreate(10, sizeof(SensorData_t));
    
    // 創建信號量
    motor_mutex = xSemaphoreCreateMutex();
    
    // 創建任務
    xTaskCreate(
        MotorControlTask, "MotorControl", 512, &g_robot_controller, 
        MOTOR_CONTROL_PRIORITY, &motor_control_task_handle
    );
    
    xTaskCreate(
        SensorReadTask, "SensorRead", 512, &g_robot_controller, 
        SENSOR_READ_PRIORITY, &sensor_read_task_handle
    );
    
    // 啟動排程器
    vTaskStartScheduler();
}
```

---

## 硬體介面設計

### 1. CAN通訊
```c
#include "stm32f4xx_hal_can.h"

// CAN配置
CAN_HandleTypeDef hcan;
CAN_TxHeaderTypeDef tx_header;
CAN_RxHeaderTypeDef rx_header;

uint8_t tx_data[8];
uint8_t rx_data[8];

// CAN初始化
void CAN_Init(void) {
    hcan.Instance = CAN1;
    hcan.Init.Prescaler = 9;
    hcan.Init.Mode = CAN_MODE_NORMAL;
    hcan.Init.SJW = CAN_SJW_1TQ;
    hcan.Init.BS1 = CAN_BS1_6TQ;
    hcan.Init.BS2 = CAN_BS2_1TQ;
    hcan.Init.TTCM = DISABLE;
    hcan.Init.ABOM = DISABLE;
    hcan.Init.AWUM = DISABLE;
    hcan.Init.NART = DISABLE;
    hcan.Init.RFLM = DISABLE;
    hcan.Init.TXFP = DISABLE;
    
    HAL_CAN_Init(&hcan);
    
    // 啟動CAN
    HAL_CAN_Start(&hcan);
    
    // 啟動接收
    HAL_CAN_ActivateNotification(&hcan, CAN_IT_RX_FIFO0_MSG_PENDING);
}

// 發送關節狀態
void SendJointStatus(uint8_t joint_id, float position, float velocity) {
    // 打包數據
    tx_data[0] = joint_id;
    memcpy(&tx_data[1], &position, 4);
    memcpy(&tx_data[5], &velocity, 4);
    
    // 設定標頭
    tx_header.StdId = 0x100 + joint_id;  // 關節ID作為CAN ID
    tx_header.RTR = CAN_RTR_DATA;
    tx_header.IDE = CAN_ID_STD;
    tx_header.DLC = 8;
    tx_header.TransmitGlobalTime = DISABLE;
    
    // 發送
    if (HAL_CAN_AddTxMessage(&hcan, &tx_header, tx_data, &tx_mailbox) != HAL_OK) {
        Error_Handler();
    }
}

// CAN接收中斷回調
void HAL_CAN_RxFifo0MsgPendingCallback(CAN_HandleTypeDef *hcan) {
    if (HAL_CAN_GetRxMessage(hcan, CAN_RX_FIFO0, &rx_header, rx_data) == HAL_OK) {
        // 解析接收到的數據
        uint8_t joint_id = rx_data[0];
        float target_position;
        memcpy(&target_position, &rx_data[1], 4);
        
        // 處理關節指令
        ProcessJointCommand(joint_id, target_position);
    }
}
```

### 2. SPI通訊
```c
#include "stm32f4xx_hal_spi.h"

SPI_HandleTypeDef hspi1;

// SPI初始化
void SPI_Init(void) {
    hspi1.Instance = SPI1;
    hspi1.Init.Mode = SPI_MODE_MASTER;
    hspi1.Init.Direction = SPI_DIRECTION_2LINES;
    hspi1.Init.DataSize = SPI_DATASIZE_8BIT;
    hspi1.Init.CLKPolarity = SPI_POLARITY_LOW;
    hspi1.Init.CLKPhase = SPI_PHASE_1EDGE;
    hspi1.Init.NSS = SPI_NSS_SOFT;
    hspi1.Init.BaudRatePrescaler = SPI_BAUDRATEPRESCALER_64;
    hspi1.Init.FirstBit = SPI_FIRSTBIT_MSB;
    hspi1.Init.TIMode = SPI_TIMODE_DISABLE;
    hspi1.Init.CRCCalculation = SPI_CRCCALCULATION_DISABLE;
    
    HAL_SPI_Init(&hspi1);
}

// 讀取IMU數據
IMUData_t ReadIMU(void) {
    IMUData_t imu_data;
    uint8_t tx_buffer[6] = {0};
    uint8_t rx_buffer[6];
    
    // 讀取加速度計數據
    tx_buffer[0] = 0x29 | 0x80;  // 讀取加速度計，多位元讀取
    HAL_SPI_TransmitReceive(&hspi1, tx_buffer, rx_buffer, 6, 100);
    
    // 解析數據
    imu_data.accel_x = (int16_t)((rx_buffer[1] << 8) | rx_buffer[2]) * 0.000061f;
    imu_data.accel_y = (int16_t)((rx_buffer[3] << 8) | rx_buffer[4]) * 0.000061f;
    imu_data.accel_z = (int16_t)((rx_buffer[5] << 8) | rx_buffer[6]) * 0.000061f;
    
    return imu_data;
}
```

---

## 實時控制演算法

### 1. PID控制器
```c
typedef struct {
    float kp;           // 比例增益
    float ki;           // 積分增益
    float kd;           // 微分增益
    float target;       // 目標值
    float integral;     // 積分累積
    float prev_error;   // 上次誤差
    float output_limit; // 輸出限制
} PIDController_t;

// PID控制器初始化
void PID_Init(PIDController_t* pid, float kp, float ki, float kd, float output_limit) {
    pid->kp = kp;
    pid->ki = ki;
    pid->kd = kd;
    pid->output_limit = output_limit;
    pid->integral = 0.0f;
    pid->prev_error = 0.0f;
}

// PID控制器更新
float PID_Update(PIDController_t* pid, float current_value, float dt) {
    // 計算誤差
    float error = pid->target - current_value;
    
    // 比例項
    float p_term = pid->kp * error;
    
    // 積分項
    pid->integral += error * dt;
    float i_term = pid->ki * pid->integral;
    
    // 微分項
    float derivative = (error - pid->prev_error) / dt;
    float d_term = pid->kd * derivative;
    
    // 計算輸出
    float output = p_term + i_term + d_term;
    
    // 限制輸出
    if (output > pid->output_limit) {
        output = pid->output_limit;
        // 防止積分飽和
        pid->integral -= (output - pid->output_limit) / pid->ki;
    } else if (output < -pid->output_limit) {
        output = -pid->output_limit;
        pid->integral -= (output + pid->output_limit) / pid->ki;
    }
    
    // 更新上次誤差
    pid->prev_error = error;
    
    return output;
}

// 關節PID控制
void JointPIDControl(RobotController_t* controller) {
    static PIDController_t joint_pids[12];
    static uint8_t initialized = 0;
    
    if (!initialized) {
        // 初始化所有關節PID控制器
        for (int i = 0; i < 12; i++) {
            PID_Init(&joint_pids[i], 2.0f, 0.1f, 0.05f, 20000.0f);
        }
        initialized = 1;
    }
    
    // 控制迴路
    for (int i = 0; i < 12; i++) {
        float current_pos = GetJointPosition(controller, i);
        float target_pos = controller->target_positions[i];
        
        joint_pids[i].target = target_pos;
        float pwm_output = PID_Update(&joint_pids[i], current_pos, 0.01f);  // 10Hz控制
        
        SetJointPosition(controller, i, (uint32_t)pwm_output);
    }
}
```

### 2. 卡爾曼濾波器
```c
typedef struct {
    float state[2];      // [位置, 速度]
    float covariance[2][2];
    float process_noise[2][2];
    float measurement_noise;
} KalmanFilter_t;

// 卡爾曼濾波器初始化
void Kalman_Init(KalmanFilter_t* kf) {
    // 初始狀態
    kf->state[0] = 0.0f;  // 位置
    kf->state[1] = 0.0f;  // 速度
    
    // 初始協方差矩陣
    kf->covariance[0][0] = 1.0f;
    kf->covariance[0][1] = 0.0f;
    kf->covariance[1][0] = 0.0f;
    kf->covariance[1][1] = 1.0f;
    
    // 過程噪聲
    kf->process_noise[0][0] = 0.01f;
    kf->process_noise[0][1] = 0.0f;
    kf->process_noise[1][0] = 0.0f;
    kf->process_noise[1][1] = 0.01f;
    
    // 測量噪聲
    kf->measurement_noise = 0.1f;
}

// 卡爾曼濾波器預測
void Kalman_Predict(KalmanFilter_t* kf, float dt) {
    // 狀態轉移矩陣 F
    float F[2][2] = {{1.0f, dt}, {0.0f, 1.0f}};
    
    // 預測狀態
    float new_state[2];
    new_state[0] = F[0][0] * kf->state[0] + F[0][1] * kf->state[1];
    new_state[1] = F[1][0] * kf->state[0] + F[1][1] * kf->state[1];
    
    // 預測協方差
    float new_covariance[2][2];
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            new_covariance[i][j] = 0.0f;
            for (int k = 0; k < 2; k++) {
                for (int l = 0; l < 2; l++) {
                    new_covariance[i][j] += F[i][k] * kf->covariance[k][l] * F[j][l];
                }
            }
            new_covariance[i][j] += kf->process_noise[i][j];
        }
    }
    
    // 更新狀態和協方差
    memcpy(kf->state, new_state, sizeof(new_state));
    memcpy(kf->covariance, new_covariance, sizeof(new_covariance));
}

// 卡爾曼濾波器更新
void Kalman_Update(KalmanFilter_t* kf, float measurement) {
    // 測量矩陣 H
    float H[2] = {1.0f, 0.0f};
    
    // 計算卡爾曼增益
    float innovation_cov = kf->measurement_noise;
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            innovation_cov += H[i] * kf->covariance[i][j] * H[j];
        }
    }
    
    float kalman_gain[2];
    for (int i = 0; i < 2; i++) {
        kalman_gain[i] = 0.0f;
        for (int j = 0; j < 2; j++) {
            kalman_gain[i] += kf->covariance[i][j] * H[j];
        }
        kalman_gain[i] /= innovation_cov;
    }
    
    // 更新狀態
    float innovation = measurement - (H[0] * kf->state[0] + H[1] * kf->state[1]);
    for (int i = 0; i < 2; i++) {
        kf->state[i] += kalman_gain[i] * innovation;
    }
    
    // 更新協方差
    for (int i = 0; i < 2; i++) {
        for (int j = 0; j < 2; j++) {
            kf->covariance[i][j] -= kalman_gain[i] * H[0] * kf->covariance[0][j];
        }
    }
}
```

---

## 系統最佳化

### 1. 記憶體管理
```c
// 靜態記憶體池
#define MEMORY_POOL_SIZE 1024
static uint8_t memory_pool[MEMORY_POOL_SIZE];
static size_t memory_offset = 0;

// 自定義記憶體分配
void* custom_malloc(size_t size) {
    if (memory_offset + size > MEMORY_POOL_SIZE) {
        return NULL;  // 記憶體不足
    }
    
    void* ptr = &memory_pool[memory_offset];
    memory_offset += size;
    
    return ptr;
}

// 記憶體釋放 (簡化版，實際應用需要更複雜的管理)
void custom_free(void* ptr) {
    // 簡化實作，實際應該管理釋放的記憶體塊
}

// DMA優化
void DMA_Transfer(uint8_t* src, uint8_t* dst, uint16_t size) {
    // 配置DMA
    DMA_HandleTypeDef hdma;
    
    hdma.Instance = DMA2_Stream0;
    hdma.Init.Channel = DMA_CHANNEL_0;
    hdma.Init.Direction = DMA_MEMORY_TO_MEMORY;
    hdma.Init.PeriphInc = DMA_PINC_ENABLE;
    hdma.Init.MemInc = DMA_MINC_ENABLE;
    hdma.Init.PeriphDataAlignment = DMA_PDATAALIGN_BYTE;
    hdma.Init.MemDataAlignment = DMA_MDATAALIGN_BYTE;
    hdma.Init.Mode = DMA_NORMAL;
    hdma.Init.Priority = DMA_PRIORITY_HIGH;
    hdma.Init.FIFOMode = DMA_FIFOMODE_DISABLE;
    
    HAL_DMA_Init(&hdma);
    
    // 啟動DMA傳輸
    HAL_DMA_Start(&hdma, (uint32_t)src, (uint32_t)dst, size);
    HAL_DMA_PollForTransfer(&hdma, HAL_DMA_FULL_TRANSFER, 1000);
}
```

### 2. 效能監控
```c
// 效能計數器
typedef struct {
    uint32_t cpu_usage;
    uint32_t stack_usage;
    uint32_t heap_usage;
    uint32_t interrupt_count;
} PerformanceMetrics_t;

// CPU使用率計算
uint32_t CalculateCPUUsage(void) {
    static uint32_t idle_count = 0;
    static uint32_t total_count = 0;
    
    // 在空閒任務中增加計數
    idle_count++;
    total_count++;
    
    // 每秒計算一次使用率
    static uint32_t last_calculation = 0;
    uint32_t current_time = HAL_GetTick();
    
    if (current_time - last_calculation >= 1000) {
        uint32_t cpu_usage = 100 - ((idle_count * 100) / total_count);
        
        // 重置計數器
        idle_count = 0;
        total_count = 0;
        last_calculation = current_time;
        
        return cpu_usage;
    }
    
    return 0;
}

// 堆疊使用監控
uint32_t CheckStackUsage(TaskHandle_t task) {
    return uxTaskGetStackHighWaterMark(task);
}
```

---

## 調試與測試

### 1. SWD調試
```c
// 調試宏定義
#define DEBUG_PRINT(fmt, ...) \
    do { \
        printf("[DEBUG] %s:%d: " fmt "\n", __FILE__, __LINE__, ##__VA_ARGS__); \
    } while(0)

// 斷言宏
#define ASSERT(condition) \
    do { \
        if (!(condition)) { \
            DEBUG_PRINT("Assertion failed: %s", #condition); \
            while (1); \
        } \
    } while(0)

// 運行時檢查
void RuntimeChecks(void) {
    // 檢查堆疊溢出
    for (int i = 0; i < 12; i++) {
        uint32_t stack_usage = CheckStackUsage(motor_control_task_handle);
        ASSERT(stack_usage > 100);  // 至少保留100位元組
    }
    
    // 檢查記憶體洩漏
    uint32_t heap_free = xPortGetFreeHeapSize();
    ASSERT(heap_free > 1024);  // 至少保留1KB記憶體
}
```

### 2. 單元測試
```c
// 測試框架
typedef struct {
    const char* name;
    void (*test_func)(void);
} TestCase_t;

// PID控制器測試
void TestPIDController(void) {
    PIDController_t pid;
    PID_Init(&pid, 1.0f, 0.1f, 0.05f, 100.0f);
    
    // 測試比例控制
    pid.target = 50.0f;
    float output = PID_Update(&pid, 0.0f, 0.1f);
    ASSERT(fabs(output - 50.0f) < 1.0f);  // 應該接近50
    
    // 測試輸出限制
    pid.target = 200.0f;
    output = PID_Update(&pid, 0.0f, 0.1f);
    ASSERT(output <= 100.0f);  // 應該被限制在100
    
    DEBUG_PRINT("PID Controller tests passed");
}

// 測試套件
TestCase_t test_cases[] = {
    {"PID Controller", TestPIDController},
    // 添加更多測試...
};

void RunTests(void) {
    for (int i = 0; i < sizeof(test_cases) / sizeof(TestCase_t); i++) {
        DEBUG_PRINT("Running test: %s", test_cases[i].name);
        test_cases[i].test_func();
    }
    
    DEBUG_PRINT("All tests passed!");
}
```

---

## 最佳實踐

### 1. 程式碼組織
```c
// 模組化設計
// robot_controller.h
#ifndef ROBOT_CONTROLLER_H
#define ROBOT_CONTROLLER_H

#include "stm32f4xx_hal.h"
#include "FreeRTOS.h"

// 公共介面
void RobotController_Init(void);
void SetJointPosition(uint8_t joint_id, uint32_t position);
uint32_t GetJointPosition(uint8_t joint_id);
void ProcessJointCommand(uint8_t joint_id, float target_position);

#endif

// robot_controller.c
#include "robot_controller.h"

// 私有變數和函數
static RobotController_t g_robot_controller;
static void MotorControlTask(void* parameters);
static void SensorReadTask(void* parameters);
```

### 2. 錯誤處理
```c
// 錯誤處理系統
typedef enum {
    ERROR_NONE = 0,
    ERROR_HARDWARE_FAILURE,
    ERROR_COMMUNICATION_TIMEOUT,
    ERROR_INVALID_PARAMETER,
    ERROR_OUT_OF_MEMORY
} ErrorCode_t;

// 錯誤回報
void ReportError(ErrorCode_t error_code, const char* message) {
    DEBUG_PRINT("ERROR %d: %s", error_code, message);
    
    // 根據錯誤類型採取不同措施
    switch (error_code) {
        case ERROR_HARDWARE_FAILURE:
            // 重啟硬體
            HAL_NVIC_SystemReset();
            break;
            
        case ERROR_COMMUNICATION_TIMEOUT:
            // 重試通訊
            RetryCommunication();
            break;
            
        default:
            // 記錄錯誤並繼續運行
            break;
    }
}
```

### 3. 電源管理
```c
// 低功耗模式
void EnterLowPowerMode(void) {
    // 降低系統時鐘
    SystemCoreClockUpdate();
    
    // 關閉不必要的外設
    HAL_ADC_DeInit(&hadc_joint);
    HAL_SPI_DeInit(&hspi1);
    
    // 進入睡眠模式
    HAL_PWR_EnterSLEEPMode(PWR_MAINREGULATOR_ON, PWR_SLEEPENTRY_WFI);
}

// 喚醒系統
void WakeUpSystem(void) {
    // 重新初始化外設
    HAL_ADC_Init(&hadc_joint);
    HAL_SPI_Init(&hspi1);
}
```
