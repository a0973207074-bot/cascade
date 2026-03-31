---
name: reinforcement-learning
description: "強化學習開發實踐。環境設計、演算法選擇、訓練流程、模型部署。專注於機器人控制與運動學習。"
risk: medium
source: custom
date_added: "2026-03-31"
---

# Reinforcement Learning

> 機器人強化學習開發指南。從環境設計到模型部署的完整工作流程。

## When to Use
開發機器人控制、運動學習、決策系統時使用此技能。

---

## 核心概念

### 1. 強化學習基本要素
```python
# 環境、代理、獎勵、策略
class RobotEnvironment:
    def __init__(self):
        self.observation_space = gym.spaces.Box(low=-1, high=1, shape=(24,))
        self.action_space = gym.spaces.Box(low=-1, high=1, shape=(12,))
        
    def step(self, action):
        observation = self._get_observation()
        reward = self._calculate_reward(action)
        done = self._check_done()
        return observation, reward, done, {}
    
    def reset(self):
        return self._get_observation()
```

### 2. 獎勵函數設計
```python
def calculate_reward(self, action, state):
    # 基本移動獎勵
    forward_velocity = state[7]  # 前進速度
    reward = forward_velocity * 10.0
    
    # 姿態穩定性懲罰
    orientation_error = np.linalg.norm(state[3:6])  # 姿態誤差
    reward -= orientation_error * 5.0
    
    # 能量消耗懲罰
    energy_cost = np.sum(np.abs(action)) * 0.1
    reward -= energy_cost
    
    return reward
```

---

## 演算法選擇

### 1. PPO (Proximal Policy Optimization)
```python
import torch
import torch.nn as nn
from stable_baselines3 import PPO

class PolicyNetwork(nn.Module):
    def __init__(self, obs_dim, action_dim):
        super().__init__()
        self.net = nn.Sequential(
            nn.Linear(obs_dim, 256),
            nn.ReLU(),
            nn.Linear(256, 128),
            nn.ReLU(),
            nn.Linear(128, action_dim),
            nn.Tanh()
        )
    
    def forward(self, obs):
        return self.net(obs)

# 訓練配置
model = PPO(
    "MlpPolicy",
    env,
    policy_kwargs=dict(net_arch=[256, 128]),
    learning_rate=3e-4,
    n_steps=2048,
    batch_size=64,
    n_epochs=10,
    gamma=0.99,
    verbose=1
)
```

### 2. SAC (Soft Actor-Critic)
```python
from stable_baselines3 import SAC

# 適合連續控制空間
model = SAC(
    "MlpPolicy",
    env,
    learning_rate=3e-4,
    buffer_size=1000000,
    learning_starts=1000,
    batch_size=256,
    tau=0.005,
    gamma=0.99,
    train_freq=1,
    gradient_steps=1,
    verbose=1
)
```

---

## 環境設計

### 1. Isaac Sim整合
```python
import numpy as np
from omni.isaac.core import World
from omni.isaac.core.objects import VisualCuboid

class G1IsaacEnvironment:
    def __init__(self):
        self.world = World()
        self.robot = self._create_robot()
        self.target = self._create_target()
        
    def _create_robot(self):
        # 創建Unitree G1機器人
        from omni.isaac.unitree import UnitreeG1
        robot = UnitreeG1(prim_path="/world/robot")
        return robot
    
    def step(self, action):
        # 應用動作到機器人
        self.robot.apply_action(action)
        
        # 模擬步進
        self.world.step(render=False)
        
        # 獲取觀測
        obs = self._get_observation()
        reward = self._calculate_reward()
        done = self._check_done()
        
        return obs, reward, done, {}
```

### 2. 物理引擎配置
```python
# 物理參數設定
physics_settings = {
    "gravity": (0.0, 0.0, -9.81),
    "timestep": 1.0/60.0,
    "substeps": 2,
    "solver_position_iterations": 10,
    "solver_velocity_iterations": 5
}
```

---

## 訓練流程

### 1. 數據收集
```python
class DataCollector:
    def __init__(self, env, policy):
        self.env = env
        self.policy = policy
        self.buffer = []
    
    def collect_trajectory(self, num_steps):
        obs = self.env.reset()
        
        for _ in range(num_steps):
            action, _ = self.policy.predict(obs, deterministic=False)
            next_obs, reward, done, info = self.env.step(action)
            
            self.buffer.append({
                'obs': obs,
                'action': action,
                'reward': reward,
                'next_obs': next_obs,
                'done': done
            })
            
            obs = next_obs
            if done:
                obs = self.env.reset()
```

### 2. 模型訓練
```python
def train_model(env, total_timesteps=1000000):
    # 創建模型
    model = PPO("MlpPolicy", env, verbose=1)
    
    # 訓練回調
    callback = TrainingCallback()
    
    # 開始訓練
    model.learn(
        total_timesteps=total_timesteps,
        callback=callback,
        log_interval=1000
    )
    
    return model

class TrainingCallback(BaseCallback):
    def __init__(self):
        super().__init__()
        self.best_reward = -np.inf
    
    def _on_step(self) -> bool:
        if self.training_env.num_timesteps % 10000 == 0:
            # 評估模型性能
            mean_reward = evaluate_model(self.model)
            if mean_reward > self.best_reward:
                self.best_reward = mean_reward
                self.model.save("best_model.zip")
        
        return True
```

---

## 模型部署

### 1. 模型轉換
```python
# 訓練完成後轉換為部署格式
import torch
import torch.jit

def export_model(model, filepath):
    # 轉換為TorchScript
    dummy_input = torch.randn(1, 24)
    traced_model = torch.jit.trace(model.policy, dummy_input)
    traced_model.save(filepath)
```

### 2. 實時推理
```python
class RLInference:
    def __init__(self, model_path):
        self.model = torch.jit.load(model_path)
        self.model.eval()
    
    def predict(self, observation):
        with torch.no_grad():
            obs_tensor = torch.FloatTensor(observation).unsqueeze(0)
            action = self.model(obs_tensor)
            return action.numpy().squeeze()
```

---

## 評估與驗證

### 1. 性能指標
```python
def evaluate_model(model, num_episodes=10):
    total_rewards = []
    
    for _ in range(num_episodes):
        obs = env.reset()
        episode_reward = 0
        
        while True:
            action, _ = model.predict(obs, deterministic=True)
            obs, reward, done, _ = env.step(action)
            episode_reward += reward
            
            if done:
                break
        
        total_rewards.append(episode_reward)
    
    return {
        'mean_reward': np.mean(total_rewards),
        'std_reward': np.std(total_rewards),
        'max_reward': np.max(total_rewards)
    }
```

### 2. Sim-to-Real驗證
```python
class Sim2RealValidator:
    def __init__(self, sim_model, real_robot):
        self.sim_model = sim_model
        self.real_robot = real_robot
    
    def validate_policy(self, test_scenarios):
        results = {}
        
        for scenario in test_scenarios:
            # 模擬環境測試
            sim_reward = self._test_in_simulation(scenario)
            
            # 實機測試
            real_reward = self._test_on_robot(scenario)
            
            # 計算差距
            gap = abs(sim_reward - real_reward)
            results[scenario] = {
                'sim_reward': sim_reward,
                'real_reward': real_reward,
                'gap': gap
            }
        
        return results
```

---

## 最佳實踐

### 1. 超參數調優
```python
# Optuna超參數優化
import optuna

def objective(trial):
    # 建議超參數
    learning_rate = trial.suggest_loguniform('learning_rate', 1e-5, 1e-3)
    n_steps = trial.suggest_int('n_steps', 512, 4096)
    batch_size = trial.suggest_int('batch_size', 32, 256)
    
    # 創建模型
    model = PPO(
        "MlpPolicy",
        env,
        learning_rate=learning_rate,
        n_steps=n_steps,
        batch_size=batch_size
    )
    
    # 訓練並評估
    model.learn(total_timesteps=50000)
    mean_reward = evaluate_model(model)
    
    return mean_reward

study = optuna.create_study(direction='maximize')
study.optimize(objective, n_trials=100)
```

### 2. 安全訓練
```python
class SafeTrainingWrapper:
    def __init__(self, env, safety_limits):
        self.env = env
        self.safety_limits = safety_limits
    
    def step(self, action):
        # 檢查動作安全性
        if not self._is_safe(action):
            # 替換為安全動作
            action = self._get_safe_action()
        
        return self.env.step(action)
    
    def _is_safe(self, action):
        # 檢查關節角度限制
        return np.all(np.abs(action) < self.safety_limits)
```

---

## 故障排除

### 1. 訓練不收斂
- 檢查獎勵函數設計
- 調整學習率
- 增加網路容量
- 檢查環境隨機性

### 2. Sim-to-Real差距
- 增加環境隨機化
- 使用領域隨機化
- 收集實機數據微調
- 使用遷移學習

### 3. 部署效能問題
- 模型量化
- 簡化網路架構
- 使用TensorRT優化
- 批次推理優化
