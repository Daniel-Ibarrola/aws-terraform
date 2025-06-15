# AWS CLI

## Understanding `--region` and `--no-cli-pager`

When using the AWS Command Line Interface (CLI), you can customize the behavior of your commands using various flags. Two commonly used flags are `--region` and `--no-cli-pager`.

---

**🌍 `--region`**

The `--region` flag specifies the **AWS region** where the CLI command should be executed. This is important because many AWS services (like EC2, S3, ACM, and Load Balancers) are **regional**, meaning their resources are specific to a certain geographical region.

**✅ Syntax:**
```bash
aws <service> <operation> --region <region-name>
```

**🚫 --no-cli-pager**

By default, AWS CLI v2 opens command output in a pager (like less) when the output is long. This can be inconvenient if you’re piping the output or using it in scripts.

The --no-cli-pager flag disables this behavior and sends the output directly to your terminal or command output.

**✅ Syntax:**
```bash
aws <service> <operation> --no-cli-pager
```