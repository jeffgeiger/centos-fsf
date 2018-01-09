# CentOS-FSF

Single layer Dockerfile for [FSF](https://github.com/EmersonElectricCo/fsf) running on CentOS 7.

## Usage:

```
docker run -i -t jeffgeiger/centos-fsf

# Or, to use a local path to bring in files for analysis:
docker run -i -t -v /path/to/host/folder:/home/nonroot/workdir jeffgeiger/centos-fsf

# Then:
fsf_client.py <filename>
```
