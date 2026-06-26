# Luker Railway Template

[English](./README.md)

这是一个用于在 Railway 上一键部署 Luker 的 Docker 模板项目。它会从 `https://github.com/LaceLetho/Luker.git` 拉取源码并编译，同时补齐 Railway 部署需要的公网监听、持久化目录和 Basic Auth 默认配置。

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/templates)

发布到 Railway Template Marketplace 后，把上面的按钮链接替换成你的模板链接。

## 模板做了什么

1. 从 `LaceLetho/Luker` 拉取并编译 Luker。
2. 自动监听 Railway 注入的 `PORT`。
3. 默认启用 HTTP Basic Auth，避免公网裸奔。
4. 只要求一个 Railway 持久化卷，挂载到 `/data`。
5. 把 Luker 的可变目录映射到 `/data` 下：`config`、`data`、`plugins`、`extensions`、`backups`。

## Railway 部署步骤

1. 用这个仓库创建 Railway service。
2. 给服务挂载持久化卷到 `/data`。
3. 在 service variables 里设置 `LUKER_PASSWORD`。
4. 给服务生成 Railway 公网域名。

## 环境变量

| 变量 | 必填 | 默认值 | 说明 |
| --- | --- | --- | --- |
| `LUKER_PASSWORD` | 是 | - | HTTP Basic Auth 密码。 |
| `LUKER_USERNAME` | 否 | `luker` | HTTP Basic Auth 用户名。 |
| `LUKER_PERSIST_DIR` | 否 | `/data` | 持久化根目录。 |
| `LUKER_REF` | 否 | 仓库默认分支 | 要拉取并编译的分支或 tag。它在 Docker 构建阶段读取，修改后需要重新部署。 |

Luker 自身还支持 `SILLYTAVERN_*` 形式的配置覆盖。这个模板会在启动时注入 Railway 所需的安全默认值。

## 持久化内容

`/data` 卷内会保存：

| 路径 | 用途 |
| --- | --- |
| `/data/config` | `config.yaml` 和运行时配置。 |
| `/data/data` | 用户数据、聊天、素材、缓存和 secrets。 |
| `/data/plugins` | 服务端插件。 |
| `/data/extensions` | 第三方前端扩展。 |
| `/data/backups` | 备份文件。 |

## 本地校验

```bash
npm test
```

## 本地 Docker 运行

```bash
docker build -t luker-railway-template .
docker run --rm -p 8000:8000 \
  -e PORT=8000 \
  -e LUKER_PASSWORD=change-me \
  -v luker-data:/data \
  luker-railway-template
```

然后打开 `http://localhost:8000`，用户名为 `luker`，密码为你设置的 `LUKER_PASSWORD`。

如果本地构建时要指定分支或 tag，可以把 `LUKER_REF` 作为 build arg 传入：

```bash
docker build --build-arg LUKER_REF=release -t luker-railway-template .
```
