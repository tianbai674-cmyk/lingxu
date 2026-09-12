# 灵枢 · 源核

Wi-Fi 10.0 生物感知与脑机接口终端的概念方案页。单页 HTML，无构建步骤，无外部依赖。

## 本地打开

直接双击 `index.html`，或起一个本地服务：

```bash
bash serve.sh          # 本地 http://127.0.0.1:8899/
```

`serve.sh` 同时会通过临时隧道给出一个公网地址（不需要注册账号，进程关闭即失效）。

## 上传到 GitHub Pages

```bash
bash deploy-github.sh
```

脚本会创建仓库、推送代码并开启 Pages，成功后打印公网地址。

## 文件说明

| 文件 | 用途 |
| --- | --- |
| `index.html` | 页面本体，样式与脚本内联 |
| `assets/` | 概念渲染图，放入 `lingxu-hero.jpg`（4:5）与 `lingxu-desk.jpg`（3:2）会自动替换占位 |
| `serve.sh` | 本地静态服务 + 临时公网隧道 |
| `deploy-github.sh` | 一键上传 GitHub 并开启 Pages |
