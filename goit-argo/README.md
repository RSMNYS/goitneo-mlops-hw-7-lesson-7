# goit-argo

GitOps репозиторій для ArgoCD - Lesson 7

**Студент:** Sergij Rylskyj
**Курс:** GoIT MLOps Neoversity

## Структура

```
.
├── namespaces/
│   ├── application/
│   │   ├── ns.yaml       # Namespace application
│   │   └── nginx.yaml    # Тестовий nginx deployment
│   └── infra-tools/
│       └── ns.yaml       # Namespace infra-tools
├── application.yaml       # ArgoCD Application для MLflow
└── README.md
```

## Опис

- `namespaces/application/` - маніфести для namespace application (nginx для тестування GitOps)
- `namespaces/infra-tools/` - маніфести для namespace infra-tools
- `application.yaml` - ArgoCD Application для деплою MLflow через Helm

## ArgoCD ApplicationSet

ApplicationSet автоматично сканує директорію `namespaces/` та створює окремі Applications для кожної піддиректорії.

## Доступ до сервісів

### Nginx (тестовий)
```bash
kubectl port-forward svc/nginx -n application 8000:80
```
Відкрити: http://localhost:8000

### MLflow
```bash
kubectl port-forward svc/mlflow -n application 5000:5000
```
Відкрити: http://localhost:5000

## Автоматична синхронізація

Всі Applications налаштовані на автоматичну синхронізацію:
- `prune: true` - видалення ресурсів, яких немає в Git
- `selfHeal: true` - автоматичне виправлення змін в кластері

При `git push` змін в цей репозиторій, ArgoCD автоматично оновить ресурси в кластері.

## Як використовувати

1. ArgoCD ApplicationSet автоматично створює Applications на основі директорій у `namespaces/`
2. Кожна піддиректорія стає окремим Application
3. MLflow деплоїться окремим Application через `application.yaml`

---

**Lesson 7** - ArgoCD GitOps Deployment