FROM centos:7
MAINTAINER "Jeff Geiger" <@jeffgeiger>

USER root
RUN yum makecache fast && \
  yum install autoconf python-devel automake wget vim libtool openssl openssl-devel net-tools sudo epel-release -y && \
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 && \
  rpm -Uvh http://mirror.chpc.utah.edu/pub/repoforge/redhat/el7/en/x86_64/rpmforge/RPMS/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm && \
  rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmforge-* && \
  yum makecache fast && \
  yum install python-argparse python-pip ssdeep-devel libffi-devel unrar upx unzip cabextract git -y && \
  sed -i 's/Defaults    requiretty/#Defaults    requiretty/g' /etc/sudoers && \
  curl -LO https://github.com/plusvic/yara/archive/v3.4.0.tar.gz && \
  tar xzf v3.4.0.tar.gz && \
  cd yara-3.4.0/ && \
  ./bootstrap.sh && \
  ./configure && \
  make && \
  make install && \
  cd yara-python/ && \
  python setup.py build && \
  python setup.py install && \
  echo "/usr/local/lib" >> /etc/ld.so.conf.d/yara.conf && \
  ldconfig && \
  yum install jq -y && \
  easy_install -U setuptools && \
  pip install czipfile pefile hachoir-parser hachoir-core hachoir-regex hachoir-metadata hachoir-subfile ConcurrentLogHandler pypdf2 xmltodict rarfile ssdeep pylzma oletools pyasn1_modules pyasn1 pyelftools javatools requests && \
  cd && \
  curl -LO https://github.com/erocarrera/pefile/files/192316/pefile-2016.3.28.tar.gz && \
  tar xzf pefile-2016.3.28.tar.gz && \
  cd pefile-2016.3.28 && \
  python setup.py build && \
  python setup.py install && \
  groupadd -r nonroot && \
  useradd -r -g nonroot -d /home/nonroot -s /sbin/nologin -c "Nonroot User" nonroot && \
  mkdir /home/nonroot && \
  chown -R nonroot:nonroot /home/nonroot && \
  /usr/bin/sudo -u nonroot mkdir -pv /home/nonroot/workdir && \
  cd /home/nonroot && \
  /usr/bin/sudo -u nonroot git clone https://github.com/EmersonElectricCo/fsf.git && \
  cd fsf/ && \
  /usr/bin/sudo -u nonroot sed -i 's/\/FULL\/PATH\/TO/\/home\/nonroot/' fsf-server/conf/config.py && \
  /usr/bin/sudo -u nonroot sed -i "/^SCANNER\_CONFIG/ s/\/tmp/\/home\/nonroot\/workdir/" fsf-server/conf/config.py && \
  ldconfig && \
  ln -f -s /home/nonroot/fsf/fsf-server/main.py /usr/local/bin/ && \
  ln -f -s /home/nonroot/fsf/fsf-client/fsf_client.py /usr/local/bin/ && \
  yum clean all -y && \
  rm -rf /var/cache/yum/*

USER nonroot
ENV HOME /home/nonroot
ENV USER nonroot
WORKDIR /home/nonroot/workdir

ENTRYPOINT sed -i "/^SERVER_CONFIG/ s/127\.0\.0\.1/$(hostname -i)/" /home/nonroot/fsf/fsf-client/conf/config.py && main.py start && printf "\n\n" && echo "<----->" && echo "FSF server daemonized!" &&  echo "<----->" && printf "\n" && echo "Invoke fsf_client.py by giving it a file as an argument:" && printf "\n" && echo "fsf_client.py <file>"  && printf "\n" && echo "Alternatively, Invoke fsf_client.py by giving it a file as an argument and pass to jq so you can interact extensively with the JSON output:" && printf "\n" && echo "fsf_client.py <file> | jq - C . | less -r" && printf "\n" && echo "To access all of the subobjects that are recursively processed, simply add --full when invoking fsf_client.py:" && printf "\n" && echo "fsf_client.py <file> --full" && printf "\n" && /bin/bash
