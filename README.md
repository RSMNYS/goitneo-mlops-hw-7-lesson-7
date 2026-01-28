# ArgoCD + MLflow GitOps Deployment (Lesson 7)

> **Студент:** Sergij Rylskyj
> **Курс:** GoIT MLOps Neoversity
> **Завдання:** Розгорнути ArgoCD у Kubernetes через Terraform та налаштувати GitOps для MLflow

---

## 📋 Зміст

1. [Опис проєкту](#опис-проєкту)
2. [Структура проєкту](#структура-проєкту)
3. [Передумови](#передумови)
4. [Швидкий старт](#швидкий-старт)
5. [Детальні інструкції](#детальні-інструкції)
6. [Перевірка роботи](#перевірка-роботи)
7. [Доступ до сервісів](#доступ-до-сервісів)
8. [Очищення ресурсів](#очищення-ресурсів)

---

## 📖 Опис проєкту

Цей проєкт демонструє повний цикл GitOps з використанням ArgoCD:

1. **Terraform** розгортає EKS кластер в AWS
2. **Terraform** встановлює ArgoCD в кластер як Helm release
3. **ArgoCD ApplicationSet** автоматично сканує Git-репозиторій та створює Applications
4. **ArgoCD Applications** автоматично деплоять та синхронізують застосунки з Git
5. Будь-які зміни в Git автоматично застосовуються в кластері (GitOps)

**Що деплоїться:**
- ✅ Namespaces: `infra-tools`, `application`
- ✅ Тестовий Nginx (для перевірки GitOps)
- ✅ MLflow (через Helm chart)

---

## 🏗 Структура проєкту

```
.
├── STEP_BY_STEP_GUIDE.md          # 📚 Детальна покрокова інструкція (ПОЧНІТЬ ЗВІДСИ!)
├── README.md                       # 📄 Цей файл - короткий опис
├── terraform/
│   ├── eks/                        # 🏗 Terraform для створення EKS кластера
│   │   ├── backend.tf
│   │   ├── provider.tf
│   │   ├── terraform.tf
│   │   ├── variables.tf
│   │   ├── vpc.tf
│   │   ├── eks.tf
│   │   └── outputs.tf
│   └── argocd/                     # 🚀 Terraform для деплою ArgoCD
│       ├── backend.tf
│       ├── provider.tf
│       ├── terraform.tf
│       ├── variables.tf
│       ├── data.tf
│       ├── main.tf
│       ├── outputs.tf
│       └── values/
│           └── argocd-values.yaml
├── goit-argo-templates/            # 📦 Шаблони для окремого Git-репозиторію
│   ├── namespaces/
│   │   ├── application/
│   │   │   ├── ns.yaml
│   │   │   └── nginx.yaml
│   │   └── infra-tools/
│   │       └── ns.yaml
│   ├── application.yaml            # ArgoCD Application для MLflow
│   └── README.md
└── screens/                        # 📸 Директорія для скріншотів

```

**⚠️ ВАЖЛИВО:** Після створення EKS кластера, потрібно створити окремий публічний GitHub-репозиторій `goit-argo` та скопіювати туди вміст директорії `goit-argo-templates/`.

---

## ✅ Передумови

### Встановлені інструменти:
- [Terraform](https://developer.hashicorp.com/terraform/install) >= 1.5.0
- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) >= 2.x
- [kubectl](https://kubernetes.io/docs/tasks/tools/) >= 1.28
- [Helm](https://helm.sh/docs/intro/install/) >= 3.12

### AWS облікові дані:
- AWS Access Key ID
- AWS Secret Access Key
- Налаштований AWS CLI profile: `sergijrylskyj`

### Git:
- Обліковий запис на GitHub
- Git встановлений локально

---

## 🚀 Швидкий старт

### 1. Налаштування AWS CLI

```bash
aws configure --profile sergijrylskyj
# Введіть AWS Access Key, Secret Key, region: eu-north-1
```

### 2. Створення S3 bucket для Terraform state

```bash
aws s3 mb s3://mlops-tfstate-sergijrylskyj --region eu-north-1 --profile sergijrylskyj

aws s3api put-bucket-versioning \
  --bucket mlops-tfstate-sergijrylskyj \
  --versioning-configuration Status=Enabled \
  --profile sergijrylskyj \
  --region eu-north-1
```

### 3. Створення EKS кластера

```bash
cd terraform/eks
terraform init
terraform plan
terraform apply  # Займе ~15-20 хвилин
```

### 4. Налаштування kubectl

```bash
aws eks update-kubeconfig \
  --region eu-north-1 \
  --name goit-eks \
  --profile sergijrylskyj

kubectl get nodes
```

### 5. Створення GitHub репозиторію для GitOps

1. Створіть новий **публічний** репозиторій на GitHub з назвою `goit-argo`
2. Клонуйте його локально
3. Скопіюйте вміст директорії `goit-argo-templates/` в новий репозиторій
4. Закомітьте та запуште зміни

```bash
cd ~/
git clone https://github.com/YOUR_GITHUB_USERNAME/goit-argo.git
cd goit-argo

# Скопіюйте файли з goit-argo-templates/
cp -r ~/goitneo-mlops-hw-7-lesson-7/goit-argo-templates/* .

git add .
git commit -m "Initial structure for GitOps"
git push origin main
```

### 6. Оновлення URL репозиторію в Terraform

Відкрийте файл `terraform/argocd/variables.tf` та змініть:

```hcl
variable "app_repo_url" {
  description = "Публічний Git-репозиторій з маніфестами"
  type        = string
  default     = "https://github.com/YOUR_GITHUB_USERNAME/goit-argo.git"  # ← Змініть тут
}
```

### 7. Розгортання ArgoCD

```bash
cd terraform/argocd
terraform init -reconfigure
terraform plan
terraform apply
```

### 8. Перевірка ArgoCD

```bash
# Перевірка pod-ів
kubectl get pods -n infra-tools

# Отримання паролю
kubectl -n infra-tools get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

# Port-forward для UI
kubectl port-forward svc/argocd-server -n infra-tools 8080:80
```

Відкрийте: http://localhost:8080
- Логін: `admin`
- Пароль: з команди вище

### 9. Перевірка Applications

```bash
# Перевірка Applications
kubectl get applications -n infra-tools

# Має з'явитися:
# - ns-application
# - ns-infra-tools
# - mlflow

# Перевірка pod-ів MLflow
kubectl get pods -n application
```

### 10. Доступ до MLflow

```bash
kubectl port-forward svc/mlflow -n application 5000:5000
```

Відкрийте: http://localhost:5000

---

## 📚 Детальні інструкції

**⚠️ ОБОВ'ЯЗКОВО ДО ПРОЧИТАННЯ:** [STEP_BY_STEP_GUIDE.md](STEP_BY_STEP_GUIDE.md)

Детальна покрокова інструкція містить:
- Повний опис кожного кроку
- Вказівки де робити скріншоти (23 скріншоти)
- Troubleshooting секцію
- Чеклист для здачі завдання
- Шаблони всіх файлів
- Коди всіх Terraform конфігурацій

---

## 🔍 Перевірка роботи

### Terraform для ArgoCD

```bash
cd terraform/argocd
terraform init -reconfigure
terraform plan
terraform apply
```

**Очікуваний результат:**
- Створено namespace `infra-tools`
- Встановлено ArgoCD через Helm
- Створено ApplicationSet для сканування Git

### ArgoCD pod-и

```bash
kubectl get pods -n infra-tools
```

**Очікуваний результат:**
```
NAME                                                READY   STATUS    RESTARTS   AGE
argocd-application-controller-0                     1/1     Running   0          5m
argocd-applicationset-controller-xxx                1/1     Running   0          5m
argocd-dex-server-xxx                               1/1     Running   0          5m
argocd-notifications-controller-xxx                 1/1     Running   0          5m
argocd-redis-xxx                                    1/1     Running   0          5m
argocd-repo-server-xxx                              1/1     Running   0          5m
argocd-server-xxx                                   1/1     Running   0          5m
```

### Applications

```bash
kubectl get applications -n infra-tools
```

**Очікуваний результат:**
```
NAME              SYNC STATUS   HEALTH STATUS
mlflow            Synced        Healthy
ns-application    Synced        Healthy
ns-infra-tools    Synced        Healthy
```

### MLflow pod-и

```bash
kubectl get pods -n application
```

**Очікуваний результат:**
```
NAME                      READY   STATUS    RESTARTS   AGE
mlflow-xxxxxxxxxx-xxxxx   1/1     Running   0          3m
nginx-xxxxxxxxxx-xxxxx    1/1     Running   0          5m
```

---

## 🌐 Доступ до сервісів

### ArgoCD UI

```bash
# Terminal 1: Port-forward
kubectl port-forward svc/argocd-server -n infra-tools 8080:80

# Браузер: http://localhost:8080
# Логін: admin
# Пароль: (отримайте командою нижче)
kubectl -n infra-tools get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo
```

### MLflow UI

```bash
# Terminal 2: Port-forward
kubectl port-forward svc/mlflow -n application 5000:5000

# Браузер: http://localhost:5000
```

### Nginx (тестовий)

```bash
# Terminal 3: Port-forward
kubectl port-forward svc/nginx -n application 8000:80

# Браузер: http://localhost:8000
```

---

## 📸 Скріншоти

Всі скріншоти зберігаються в директорії `screens/`:

| Етап | Скріншот | Опис |
|------|----------|------|
| **AWS** | `00_aws_identity.png` | AWS identity перевірка |
| **S3** | `01_s3_bucket.png` | Створений S3 bucket |
| **EKS** | `02_eks_terraform_init.png` | Terraform init для EKS |
| **EKS** | `03_eks_terraform_apply.png` | Terraform apply для EKS |
| **EKS** | `04_kubectl_get_nodes.png` | kubectl get nodes |
| **ArgoCD** | `05_argocd_terraform_init.png` | Terraform init для ArgoCD |
| **ArgoCD** | `06_argocd_terraform_apply.png` | Terraform apply для ArgoCD |
| **ArgoCD** | `07_argocd_get_pods.png` | ArgoCD pods |
| **ArgoCD** | `08_argocd_admin_password.png` | ArgoCD пароль |
| **ArgoCD** | `09_argocd_login_page.png` | ArgoCD UI логін |
| **ArgoCD** | `10_argocd_ui_empty.png` | ArgoCD UI порожній |
| **Git** | `11_github_repo_created.png` | GitHub goit-argo створено |
| **Git** | `12_github_namespaces_structure.png` | Структура namespaces |
| **ApplicationSet** | `13_argocd_terraform_apply_with_repo.png` | Terraform з repo URL |
| **ApplicationSet** | `14_applications_from_applicationset.png` | Applications від ApplicationSet |
| **Nginx** | `15_nginx_pods.png` | Nginx pods |
| **MLflow** | `16_github_application_yaml.png` | application.yaml в GitHub |
| **MLflow** | `17_applications_with_mlflow.png` | Applications з MLflow |
| **MLflow** | `18_mlflow_pods.png` | MLflow pods |
| **MLflow** | `19_mlflow_ui.png` | MLflow UI |
| **ArgoCD UI** | `20_argocd_all_applications.png` | Всі Applications |
| **ArgoCD UI** | `21_argocd_mlflow_details.png` | Деталі MLflow |
| **GitHub** | `22_github_lesson7_branch.png` | Гілка lesson-7 |
| **Архів** | `23_archive_created.png` | Створений архів |

**Детальні вказівки коли робити кожен скріншот:** див. [STEP_BY_STEP_GUIDE.md](STEP_BY_STEP_GUIDE.md)

---

## 🧹 Очищення ресурсів

**⚠️ ВАЖЛИВО:** Виконуйте тільки після перевірки ментором!

```bash
# 1. Видалення MLflow Application
kubectl delete application mlflow -n infra-tools

# 2. Видалення ArgoCD
cd terraform/argocd
terraform destroy

# 3. Видалення EKS кластера (займе ~10-15 хвилин)
cd ../eks
terraform destroy

# 4. ОПЦІОНАЛЬНО: Видалення S3 bucket
# aws s3 rb s3://mlops-tfstate-sergijrylskyj --force --profile sergijrylskyj
```

**💰 Вартість зберігання S3:** $0.023 за GB/місяць (практично безкоштовно для пустого бакету)

---

## 📊 Критерії оцінювання

| Критерій | Бали |
|----------|------|
| ArgoCD через Terraform | 30 |
| Application у Git | 25 |
| Успішний деплой Helm-сервісу | 30 |
| README.md з інструкціями | 15 |
| **Разом** | **100** |

---

## 📦 Формат здачі

1. Створіть гілку `lesson-7`:
   ```bash
   git checkout -b lesson-7
   git add .
   git commit -m "Complete lesson 7: ArgoCD + MLflow GitOps"
   git push origin lesson-7
   ```

2. Створіть архів:
   ```bash
   cd ..
   zip -r "ДЗ7_Rylskyj_Sergij.zip" goitneo-mlops-hw-7-lesson-7 \
     -x "*.terraform/*" -x "*/.git/*" -x "*/.DS_Store"
   ```

3. Завантажте архів в LMS
4. Додайте посилання на гілку `lesson-7`

---

## 🔗 Посилання

- **Основний репозиторій:** [goitneo-mlops-hw-7-lesson-7](https://github.com/YOUR_GITHUB_USERNAME/goitneo-mlops-hw-7-lesson-7/tree/lesson-7)
- **GitOps репозиторій:** [goit-argo](https://github.com/YOUR_GITHUB_USERNAME/goit-argo)

---

## 📚 Ресурси

- [ArgoCD Documentation](https://argo-cd.readthedocs.io/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Best Practices](https://aws.github.io/aws-eks-best-practices/)
- [MLflow Documentation](https://mlflow.org/docs/latest/index.html)
- [Kubernetes Documentation](https://kubernetes.io/docs/home/)

---

## ❓ Troubleshooting

Детальний troubleshooting guide у файлі [STEP_BY_STEP_GUIDE.md](STEP_BY_STEP_GUIDE.md#troubleshooting)

**Основні проблеми:**
- ArgoCD pod не запускається → `kubectl describe pod <pod-name> -n infra-tools`
- MLflow не синхронізується → Примусова синхронізація через UI або kubectl
- Не можу підключитися до EKS → `aws eks update-kubeconfig`
- Port-forward не працює → Перевірте що pod працює

---

## 👨‍💻 Автор

**Sergij Rylskyj**
GoIT MLOps Neoversity - Lesson 7

---

## 📄 Ліцензія

Цей проєкт створений для навчальних цілей в рамках курсу GoIT MLOps Neoversity.

---

**🚀 Успіхів у виконанні завдання!**

Якщо виникнуть питання - звертайтеся до ментора у Slack.
