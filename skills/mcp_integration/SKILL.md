---
name: mcp-integration
description: "Model Context Protocol整合系統。智能選擇、配置、管理MCP伺服器，擴展AI助理的能力邊界。"
risk: low
source: cascade-core
date_added: "2026-03-31"
---

# MCP Integration - MCP整合系統

> 智能管理Model Context Protocol伺服器，為每個專案提供最適配的工具擴展。

## 🎯 MCP伺服器庫

### 🗄️ **資料庫相關**
```json
{
  "postgres-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-postgres"],
    "env": {"DATABASE_URL": "postgresql://localhost/db"},
    "use_cases": ["database_query", "schema_analysis", "migration"]
  },
  "redis-mcp": {
    "command": "npx", 
    "args": ["-y", "@modelcontextprotocol/server-redis"],
    "env": {"REDIS_URL": "redis://localhost:6379"},
    "use_cases": ["caching", "session_management", "queue"]
  },
  "mongodb-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-mongodb"],
    "env": {"MONGODB_URL": "mongodb://localhost:27017"},
    "use_cases": ["document_query", "aggregation", "indexing"]
  }
}
```

### 🐍 **Python生態**
```json
{
  "python-mcp-server": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-python"],
    "env": {"PYTHONPATH": "./src"},
    "use_cases": ["code_execution", "package_management", "testing"]
  },
  "jupyter-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-jupyter"],
    "env": {"JUPYTER_PATH": "./notebooks"},
    "use_cases": ["data_analysis", "visualization", "ml_experiments"]
  },
  "pip-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-pip"],
    "env": {"VIRTUAL_ENV": "./venv"},
    "use_cases": ["package_install", "dependency_resolution", "environment"]
  }
}
```

### 🌐 **Web開發**
```json
{
  "nodejs-mcp-server": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-nodejs"],
    "env": {"NODE_PATH": "./node_modules"},
    "use_cases": ["package_management", "build_tools", "testing"]
  },
  "npm-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-npm"],
    "env": {"NPM_CONFIG_PREFIX": "./.npm"},
    "use_cases": ["dependency_management", "scripts", "publishing"]
  },
  "webpack-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-webpack"],
    "env": {"WEBPACK_CONFIG": "./webpack.config.js"},
    "use_cases": ["bundling", "optimization", "dev_server"]
  }
}
```

### ☁️ **雲端服務**
```json
{
  "aws-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-aws"],
    "env": {"AWS_REGION": "us-west-2"},
    "use_cases": ["ec2_management", "s3_operations", "lambda_functions"]
  },
  "gcp-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-gcp"],
    "env": {"GOOGLE_APPLICATION_CREDENTIALS": "./credentials.json"},
    "use_cases": ["compute_engine", "storage", "cloud_functions"]
  },
  "azure-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-azure"],
    "env": {"AZURE_SUBSCRIPTION_ID": "your-subscription-id"},
    "use_cases": ["vm_management", "storage", "app_services"]
  }
}
```

### 🤖 **AI/ML相關**
```json
{
  "tensorflow-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-tensorflow"],
    "env": {"TF_MODELS_DIR": "./models"},
    "use_cases": ["model_training", "inference", "tensorboard"]
  },
  "pytorch-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-pytorch"],
    "env": {"PYTORCH_MODELS_DIR": "./models"},
    "use_cases": ["neural_networks", "gpu_training", "model_export"]
  },
  "huggingface-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-huggingface"],
    "env": {"HF_TOKEN": "your-hf-token"},
    "use_cases": ["model_download", "fine_tuning", "inference"]
  }
}
```

### 🤖 **機器人開發**
```json
{
  "ros2-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-ros2"],
    "env": {"ROS_DOMAIN_ID": "0"},
    "use_cases": ["node_management", "topic_monitoring", "launch_control"]
  },
  "gazebo-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-gazebo"],
    "env": {"GAZEBO_MODEL_PATH": "./models"},
    "use_cases": ["simulation", "model_testing", "physics"]
  },
  "opencv-mcp": {
    "command": "npx",
    "args": ["-y", "@modelcontextprotocol/server-opencv"],
    "env": {"OPENCV_MODELS": "./cv_models"},
    "use_cases": ["image_processing", "object_detection", "camera_calibration"]
  }
}
```

---

## 🔧 智能配置系統

### 1. 自動偵測與配置
```python
def auto_configure_mcp(project_path):
    """自動配置MCP伺服器"""
    # 偵測專案類型
    project_type = detect_project_type(project_path)
    
    # 選擇相關MCP
    selected_mcps = select_relevant_mcps(project_type)
    
    # 生成配置
    config = generate_mcp_config(selected_mcps)
    
    # 應用配置
    apply_mcp_config(config)
    
    return selected_mcps

def select_relevant_mcps(project_type):
    """選擇相關MCP伺服器"""
    mcp_mapping = {
        'python': ['python-mcp-server', 'jupyter-mcp', 'pip-mcp'],
        'nodejs': ['nodejs-mcp-server', 'npm-mcp', 'webpack-mcp'],
        'database': ['postgres-mcp', 'redis-mcp', 'mongodb-mcp'],
        'cloud': ['aws-mcp', 'gcp-mcp', 'azure-mcp'],
        'ml': ['tensorflow-mcp', 'pytorch-mcp', 'huggingface-mcp'],
        'robotics': ['ros2-mcp', 'gazebo-mcp', 'opencv-mcp']
    }
    
    selected = []
    for ptype in project_type:
        selected.extend(mcp_mapping.get(ptype, []))
    
    return list(set(selected))
```

### 2. 動態配置生成
```python
def generate_mcp_config(selected_mcps):
    """生成MCP配置檔案"""
    config = {
        "mcpServers": {}
    }
    
    for mcp_name in selected_mcps:
        mcp_config = get_mcp_config(mcp_name)
        if mcp_config:
            config["mcpServers"][mcp_name] = mcp_config
    
    return config

def apply_mcp_config(config):
    """應用MCP配置"""
    config_path = "/home/kenmec/.gemini/antigravity/mcp_config.json"
    
    # 讀取現有配置
    existing_config = {}
    if os.path.exists(config_path):
        with open(config_path) as f:
            existing_config = json.load(f)
    
    # 合併配置
    existing_config["mcpServers"].update(config["mcpServers"])
    
    # 寫入配置
    with open(config_path, 'w') as f:
        json.dump(existing_config, f, indent=2)
```

---

## 🚀 MCP伺服器管理

### 1. 伺服器狀態監控
```python
def monitor_mcp_servers():
    """監控MCP伺服器狀態"""
    server_status = {}
    
    for server_name in get_configured_servers():
        status = check_server_health(server_name)
        server_status[server_name] = status
    
    return server_status

def check_server_health(server_name):
    """檢查伺服器健康狀態"""
    try:
        # 嘗試連接伺服器
        response = ping_mcp_server(server_name)
        return {
            'status': 'healthy' if response else 'unhealthy',
            'last_check': datetime.now(),
            'response_time': response.get('response_time', 0)
        }
    except Exception as e:
        return {
            'status': 'error',
            'error': str(e),
            'last_check': datetime.now()
        }
```

### 2. 自動重啟機制
```python
def auto_restart_failed_servers():
    """自動重啟失敗的伺服器"""
    server_status = monitor_mcp_servers()
    
    for server_name, status in server_status.items():
        if status['status'] != 'healthy':
            print(f"重啟MCP伺服器: {server_name}")
            restart_mcp_server(server_name)
```

---

## 📊 效能最佳化

### 1. 伺服器選擇最佳化
```python
def optimize_server_selection(project_requirements):
    """最佳化伺服器選擇"""
    # 分析專案需求
    requirements = analyze_requirements(project_requirements)
    
    # 評估每個MCP伺服器的效用
    server_scores = {}
    for server in get_available_servers():
        score = calculate_server_utility(server, requirements)
        server_scores[server] = score
    
    # 選擇最高分數的伺服器
    selected_servers = sorted(server_scores.items(), key=lambda x: x[1], reverse=True)[:5]
    
    return [server for server, score in selected_servers]

def calculate_server_utility(server, requirements):
    """計算伺服器效用分數"""
    score = 0
    
    # 功能匹配度
    for req in requirements:
        if server_supports_feature(server, req):
            score += 10
    
    # 效能評分
    performance_score = get_server_performance_score(server)
    score += performance_score
    
    # 穩定性評分
    stability_score = get_server_stability_score(server)
    score += stability_score
    
    return score
```

### 2. 資源使用最佳化
```python
def optimize_resource_usage():
    """最佳化資源使用"""
    # 監控資源使用
    resource_usage = monitor_resource_usage()
    
    # 識別低使用率伺服器
    low_usage_servers = identify_low_usage_servers(resource_usage)
    
    # 暫停不必要的伺服器
    for server in low_usage_servers:
        pause_mcp_server(server)
    
    # 調整伺服器配置
    adjust_server_configurations(resource_usage)
```

---

## 🔄 持續進化

### 1. 使用模式學習
```python
def learn_mcp_usage_patterns():
    """學習MCP使用模式"""
    # 收集使用統計
    usage_stats = collect_usage_statistics()
    
    # 分析模式
    patterns = analyze_usage_patterns(usage_stats)
    
    # 更新選擇策略
    update_selection_strategy(patterns)
    
    # 優化配置
    optimize_configurations(patterns)

def analyze_usage_patterns(stats):
    """分析使用模式"""
    patterns = {
        'most_used_servers': [],
        'server_combinations': [],
        'project_type_preferences': {}
    }
    
    # 分析最常用伺服器
    patterns['most_used_servers'] = get_most_used_servers(stats)
    
    # 分析伺服器組合
    patterns['server_combinations'] = get_common_combinations(stats)
    
    # 分析專案類型偏好
    patterns['project_type_preferences'] = get_type_preferences(stats)
    
    return patterns
```

### 2. 新伺服器發現
```python
def discover_new_mcp_servers():
    """發現新的MCP伺服器"""
    # 搜尋npm registry
    new_servers = search_npm_registry("@modelcontextprotocol/server-*")
    
    # 評估新伺服器
    for server in new_servers:
        if evaluate_new_server(server):
            add_server_to_library(server)
    
    # 更新伺服器庫
    update_server_library()
```

---

## 🎯 實際應用流程

當你開啟專案時，我會：

1. **偵測專案類型**和技術需求
2. **選擇最適配的MCP伺服器**
3. **自動生成並應用配置**
4. **監控伺服器健康狀態**
5. **最佳化資源使用**
6. **學習使用模式**持續改進

**讓我為你的每個專案配置最完美的MCP工具擴展！** 🚀
