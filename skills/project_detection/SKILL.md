---
name: project-detection
description: "專案類型自動偵測系統。分析專案結構、檔案類型、依賴關係，自動識別專案類型並匹配對應技能與MCP伺服器。"
risk: low
source: cascade-core
date_added: "2026-03-31"
---

# Project Detection - 專案偵測系統

> 自動分析你的專案，智能匹配最適合的技能與工具。

## 🎯 偵測機制

### 1. 檔案結構分析
```python
def detect_project_type(project_path):
    """偵測專案類型"""
    indicators = {
        'package.json': 'frontend/nodejs',
        'requirements.txt': 'python',
        'Cargo.toml': 'rust',
        'go.mod': 'golang',
        'pom.xml': 'java/maven',
        'CMakeLists.txt': 'cpp/cmake',
        'setup.py': 'python/package',
        'Dockerfile': 'containerized',
        'docker-compose.yml': 'multi-container',
        'package.xml': 'ros2',
        'unity': 'unity-game',
        'Unreal.uproject': 'unreal-game'
    }
    
    detected_types = []
    for file, type_key in indicators.items():
        if os.path.exists(os.path.join(project_path, file)):
            detected_types.append(type_key)
    
    return detected_types
```

### 2. 依賴關係分析
```python
def analyze_dependencies(project_path):
    """分析專案依賴"""
    dependencies = {}
    
    # Python依賴
    if os.path.exists(f"{project_path}/requirements.txt"):
        with open(f"{project_path}/requirements.txt") as f:
            dependencies['python'] = [line.strip() for line in f]
    
    # Node.js依賴
    if os.path.exists(f"{project_path}/package.json"):
        import json
        with open(f"{project_path}/package.json") as f:
            package_data = json.load(f)
            dependencies['nodejs'] = list(package_data.get('dependencies', {}).keys())
    
    return dependencies
```

### 3. 技能匹配系統
```python
def match_skills(project_type, dependencies):
    """匹配相關技能"""
    skill_mapping = {
        'frontend/nodejs': [
            'react-development',
            'vue-development', 
            'typescript-patterns',
            'frontend-performance'
        ],
        'python': [
            'python-patterns',
            'python-fastapi-development',
            'django-patterns',
            'data-science-python'
        ],
        'ros2': [
            'ros2-development',
            'robotics-simulation',
            'embedded-systems'
        ],
        'containerized': [
            'docker-expert',
            'kubernetes-deployment',
            'microservices-patterns'
        ]
    }
    
    matched_skills = []
    for ptype in project_type:
        matched_skills.extend(skill_mapping.get(ptype, []))
    
    return list(set(matched_skills))  # 去重
```

---

## 🔧 MCP伺服器配置

### 1. MCP選擇邏輯
```python
def select_mcp_servers(project_type, dependencies):
    """選擇適合的MCP伺服器"""
    mcp_mapping = {
        'python': ['python-mcp-server'],
        'nodejs': ['nodejs-mcp-server'],
        'database': ['postgres-mcp', 'redis-mcp'],
        'cloud': ['aws-mcp', 'gcp-mcp'],
        'robotics': ['ros2-mcp', 'simulation-mcp'],
        'ai/ml': ['tensorflow-mcp', 'pytorch-mcp']
    }
    
    selected_mcps = []
    for dep_type, deps in dependencies.items():
        for mcp in mcp_mapping.get(dep_type, []):
            selected_mcps.append(mcp)
    
    return list(set(selected_mcps))
```

### 2. 自動配置生成
```python
def generate_mcp_config(selected_mcps):
    """生成MCP配置"""
    config = {
        "mcpServers": {}
    }
    
    for mcp in selected_mcps:
        config["mcpServers"][mcp] = get_mcp_server_config(mcp)
    
    return config

def get_mcp_server_config(mcp_name):
    """獲取MCP伺服器配置"""
    configs = {
        'python-mcp-server': {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-python"],
            "env": {"PYTHONPATH": "./src"}
        },
        'postgres-mcp': {
            "command": "npx", 
            "args": ["-y", "@modelcontextprotocol/server-postgres"],
            "env": {"DATABASE_URL": "postgresql://localhost/db"}
        }
    }
    
    return configs.get(mcp_name, {})
```

---

## 🚀 實際應用

### 1. 專案初始化
```python
def initialize_project_assistance(project_path):
    """初始化專案輔助"""
    # 偵測專案類型
    project_types = detect_project_type(project_path)
    
    # 分析依賴
    dependencies = analyze_dependencies(project_path)
    
    # 匹配技能
    skills = match_skills(project_types, dependencies)
    
    # 選擇MCP
    mcps = select_mcp_servers(project_types, dependencies)
    
    # 生成配置
    mcp_config = generate_mcp_config(mcps)
    
    return {
        'project_types': project_types,
        'skills': skills,
        'mcp_servers': mcps,
        'config': mcp_config
    }
```

### 2. 動態技能載入
```python
def load_relevant_skills(skills_list):
    """載入相關技能"""
    loaded_skills = {}
    
    for skill_name in skills_list:
        skill_path = f"/home/kenmec/.gemini/antigravity/global-skills/skills/{skill_name}"
        if os.path.exists(f"{skill_path}/SKILL.md"):
            with open(f"{skill_path}/SKILL.md") as f:
                loaded_skills[skill_name] = f.read()
    
    return loaded_skills
```

---

## 📊 支援的專案類型

### 🎨 **前端開發**
- React, Vue, Angular
- TypeScript, JavaScript
- Next.js, Nuxt.js
- Tailwind CSS, Styled Components

### ⚙️ **後端開發**  
- Node.js, Python, Go, Rust
- REST API, GraphQL
- Microservices, Monolith
- Authentication, Authorization

### 🤖 **機器學習**
- TensorFlow, PyTorch
- Scikit-learn, XGBoost
- Computer Vision, NLP
- MLOps, Model Deployment

### 🗄️ **資料庫**
- PostgreSQL, MySQL, MongoDB
- Redis, Elasticsearch
- Database Design, Optimization
- Migration, Backup

### ☁️ **雲端服務**
- AWS, GCP, Azure
- Serverless, Containers
- CI/CD, DevOps
- Monitoring, Logging

### 🤖 **機器人開發**
- ROS 2, Embedded Systems
- Computer Vision, SLAM
- Reinforcement Learning
- Hardware Integration

---

## 🔄 持續學習機制

### 1. 專案經驗積累
```python
def learn_from_project(project_path, outcome):
    """從專案中學習"""
    project_signature = generate_project_signature(project_path)
    
    # 記錄成功的技能組合
    if outcome['success']:
        save_successful_combination(project_signature, outcome['skills_used'])
    
    # 記錄失敗的嘗試
    if not outcome['success']:
        save_failed_attempt(project_signature, outcome['issues'])
```

### 2. 技能推薦優化
```python
def optimize_skill_recommendations():
    """優化技能推薦"""
    # 分析歷史成功案例
    successful_patterns = analyze_successful_projects()
    
    # 更新技能映射
    update_skill_mapping(successful_patterns)
    
    # 改進MCP選擇邏輯
    improve_mcp_selection(successful_patterns)
```

---

## 🎯 使用範例

當你開啟新專案時，我會：

1. **自動掃描**專案結構
2. **識別技術棧**和依賴
3. **匹配相關技能**從ANTIGRAVITY庫
4. **配置MCP伺服器**擴展能力
5. **提供最佳實踐**指南
6. **設定開發環境**工具鏈

**讓我為你的每個專案找到最完美的技能組合！** 🚀
