# ArgoCD + MLflow GitOps (Lesson 7)

**Студент:** Sergij Rylskyj
**Курс:** GoIT MLOps Neoversity

---

## 📖 Опис

Автоматичний деплой застосунків у Kubernetes через ArgoCD (GitOps підхід):

- ✅ ArgoCD розгорнуто через Terraform в namespace `infra-tools`
- ✅ ApplicationSet автоматично створює Applications зі структури Git
- ✅ MLflow деплоїться через ArgoCD Application (Helm chart)
- ✅ Nginx для тестування GitOps

---

## 🏗 Структура

```
.
├── terraform/argocd/          # Terraform конфігурація ArgoCD
│   ├── main.tf
│   ├── variables.tf
│   ├── applicationset.yaml    # ApplicationSet маніфест
│   └── values/
│       └── argocd-values.yaml
│
├── goit-argo/                 # GitOps маніфести (mirror з окремого repo)
│   ├── namespaces/
│   │   ├── application/       # Namespace + nginx
│   │   └── infra-tools/       # Namespace
│   ├── application.yaml       # MLflow Application
│   └── README.md
│
├── screens/                   # Скріншоти для здачі
└── README.md
```

---

## 🚀 Як це працює

1. **Terraform** встановлює ArgoCD в EKS кластер
2. **ApplicationSet** сканує GitHub репозиторій [goit-argo](https://github.com/RSMNYS/goit-argo)
3. Для кожної директорії в `namespaces/*` створюється окремий Application
4. **MLflow Application** деплоїть Helm chart в namespace `application`
5. Будь-які зміни в Git автоматично синхронізуються в кластер

---

## ✅ Що розгорнуто

### ArgoCD Applications:
- `ns-application` - створює namespace + nginx
- `ns-infra-tools` - створює namespace
- `mlflow` - деплоїть MLflow через Helm

### Pods:
```bash
kubectl get pods -n infra-tools  # ArgoCD (~7 pods)
kubectl get pods -n application  # nginx + mlflow
```

---

## 🌐 Доступ до сервісів

### ArgoCD UI
```bash
# Отримати пароль
kubectl -n infra-tools get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

# Port-forward
kubectl port-forward svc/argocd-server -n infra-tools 8080:80
```
Відкрити: http://localhost:8080 (логін: `admin`)

### MLflow UI
```bash
kubectl port-forward svc/mlflow -n application 5000:5000
```
Відкрити: http://localhost:5000

### Nginx (тестовий)
```bash
kubectl port-forward svc/nginx -n application 8000:80
```
Відкрити: http://localhost:8000

---

## 📋 Команди для перевірки

```bash
# ArgoCD
kubectl get pods -n infra-tools
kubectl get applications -n infra-tools

# Applications
kubectl get pods -n application
kubectl get svc -n application

# Перевірка синхронізації
kubectl get applications -n infra-tools -o wide
```

---

## 🔗 Посилання

- **Основний репозиторій:** [goitneo-mlops-hw-7-lesson-7](https://github.com/RSMNYS/goitneo-mlops-hw-7-lesson-7/tree/lesson-7)
- **GitOps репозиторій:** [goit-argo](https://github.com/RSMNYS/goit-argo)

---

**Lesson 7** - ArgoCD GitOps Deployment
GoIT MLOps Neoversity © 2026
