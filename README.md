<h1>Repository URL</h1>

<h2>

[Project Repository](https://github.com/karakoc49/java-test)

<h2>



<h1>1. Dağıtım Seçimi ve Sanal Makinelerin Kurulumu</h1>

Her ne kadar gereksiz snap paketlerinden ve open source ilkesine uygun olmamasını düşündüğümden dolayı Ubuntu'dan pekte haz etmesem de dağıtım olarak Ubuntu LTS Sunucu 20.04 sürümü kullanmaya karar verdim. Debian 11 de kullanabilirdim ama kurulum işlemini basit tutmak istedim.

Öncelikle 2 tane sanal makine oluşturdum. Bu sanal makinelerden ilkini Jenkins'i koşturan sunucu olarak (jenkins_server@ubuntuserver), diğerini ise Jenkins agent ve konteyner imajını çalıştıracağım ikinci sunucu (jenkins_agent@ubuntuserver) olarak oluşturdum. Aynı makinede iki ayrı kullanıcı açmadım yanlış anlaşılmasın sadece nedense iki makinenin de adını aynı koydum :)

<h2>Kurduğum sunucuları ve içindeki programların hepsinin dilini İngilizce(en_us) olarak kurduğumu belirtmek isterim.</h2>

<h1>2. Gerekli programların kurulumu</h2>

<h3>Burada yapılacak adımları ilk sunucu için anlattım ama "*" işareti koyduklarım ikinci sunucu için de yapılacak.</h3>
<br>

Öncelikle sistemi güncelleyerek başladım.
```console
* jenkins_server@ubuntuserver:~$ sudo apt update && sudo apt upgrade
```
<br>

Sunucuya ssh ile bağlanıp kullanmak daha rahat geliyordu bende ssh bağlantısı için önce firewallı(ufw) etkinleştirdim ve ssh için gerekli olan 22 numaralı portu açtım.

```console
* jenkins_server@ubuntuserver:~$ ufw enable
* jenkins_server@ubuntuserver:~$ ufw allow ssh
```
<br>

Ardından Jenkins çalışmak için Java'ya ihtiyaç duyuyor bu yüzden Java yükledim.
```console
* jenkins_server@ubuntuserver:~$ sudo apt install openjdk-11-jre-headless
```

<h2>Sıra Jenkins'i kurmaya geldi.</h2>
<br>

Repository keyleri sisteme ekledim.
```console
jenkins_server@ubuntuserver:~$ wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo apt-key add -
```

```console
jenkins_server@ubuntuserver:~$ sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
```
<br>

Repoları yeniledim.
```console
jenkins_server@ubuntuserver:~$ sudo apt update
```
<br>

Bağımlılıklarıyla(dependency) birlikte Jenkins'i kurdum.
```console
jenkins_server@ubuntuserver:~$ sudo apt install jenkins
```
<br>

Jenkins'i şimdi ve her başlangışta başlatmak için.
```console
jenkins_server@ubuntuserver:~$ sudo systemctl start jenkins
jenkins_server@ubuntuserver:~$ sudo systemctl enable jenkins
```
<br>

Jenkins web tabanlı bir uygulama. Bu yüzden varsayılan olarak http üzerinden çalışmak için 8080 portunu, https üzerinden çalışmak için ise 8443 portunu kullanıyor. Bu portları açmak için ufw kullanıyorum.
```console
jenkins_server@ubuntuserver:~$ sudo ufw allow 8080
jenkins_server@ubuntuserver:~$ sudo ufw allow 8443
```
<br>

Jenkins'in ilk kurulumunu gerçekleştirmek için http://localhost:8080 adresine gidiyorum. İlk kurulumu anlatmaya fazla takılmak istemiyorum oldukça basit bir işlem zaten. Kısacası "Install suggested plugins" seçeneğini seçerek Jenkins'in benim için en uygun göreceği pluginleri seçiyorum.
<br>

İlk kullanıcımı oluşturduktan sonra Jenkins URL kısmını değiştirmiyorum ve "Start using Jenkins" butonuna tıklayarak temel Jenkins kurulumumu tamamlıyorum.
<br><br>

<h2>Docker kurulumu</h2>
<br>

Docker'ı yüklerken kullanacağımız programları yüklüyoruz.
```console
* jenkins_server@ubuntuserver:~$ sudo apt install ca-certificates curl gnupg lsb-release
```
<br>

Docker'ın GPG keylerini sisteme ekliyorum.
```console
* jenkins_server@ubuntuserver:~$ sudo mkdir -p /etc/apt/keyrings
* jenkins_server@ubuntuserver:~$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
```
<br>

Repoyu sisteme ekliyorum.
```console
* jenkins_server@ubuntuserver:~$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
```
<br>

Repoları güncelleyip ardından Docker'ı yüklüyorum.
```console
* jenkins_server@ubuntuserver:~$ sudo apt update
* jenkins_server@ubuntuserver:~$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
```
<br>

Docker'ı şimdi ve her başlangışta başlatmak için.
```console
* jenkins_server@ubuntuserver:~$ sudo systemctl start docker
* jenkins_server@ubuntuserver:~$ sudo systemctl enable docker
```
<br>

<h1>3. Jenkins SSL</h1>
Bu aşamada Jenkins servisine kullanıcıların sadece ssl ile erişebilmesini sağlayabildim fakat geçerli bir dns adresim olmadığı için çeşitli ssl sertifika servislerini kullanamadım(Let's Encrypt, Certbot). Bundan dolayı Jenkins servisine sadece ssl ile bağlantı sağlanabiliyor ama malesef geçerli bir sertifika yok.
<br><br>

Jenkins home dizininin içine(/var/lib/jenkins) sertifika belgelerini tutacağım .ssl dizini oluşturuyorum.
```console
jenkins_server@ubuntuserver:~$ sudo mkdir /var/lib/jenkins/.ssl
```
<br>

Openssl yardımı ile SSL keylerimi oluşturuyorum.
```console
jenkins_server@ubuntuserver:~$ openssl req -x509 -newkey rsa:4096 -keyout jenkins.key -out jenkins.pem -days 3650
```
<br>

SSL keylerimi .p12 formatına dönüştürmem gerek.
```console
jenkins_server@ubuntuserver:~$ sudo openssl pkcs12 -export -keypbe PBE-SHA1-3DES -certpbe PBE-SHA1-3DES -export -in jenkins.pem -inkey jenkins.key -name jenkins -out jkeystore.p12
```
<br>

.p12 formatındaki keylerimi Jenkins'in anlayacağı .jks formatına çevirmeliyim.
```console
jenkins_server@ubuntuserver:~$ sudo keytool -importkeystore -destkeystore jkeystore.jks -deststoretype PKCS12 -srcstoretype PKCS12 -srckeystore jkeystore.p12
```
<br>

Sertifika için .crt dosyasını oluşturuyorum.
```console
jenkins_server@ubuntuserver:~$ sudo keytool -export -keystore jkeystore.jks -alias jenkins -file jenkins.cloud.local.crt
```
<br>

Bu oluşturuğum .crt dosyasını cacerts store'a importluyorum.
```console
jenkins_server@ubuntuserver:~$ sudo keytool -importcert -file jenkins.cloud.local.crt -alias jenkins -keystore -cacerts
```
Bu aşamaları yapma sebebim; sertifika dosyalarını oluşturmak, bu dosyaları Jenkins'in anlayacağı uzantıya çevirmek ve güvenilir sertifikalar listesine eklemekti.
<br><br>

Jenkins dosyalarının sahipliğinin jenkins kullanıcısına olması gerekiyor ama yeni oluşturduğum dosyaların sahipliği root kullanıcısına ait. Bunun için tüm jenkins klasörünün sahipliğini alt dosyaları da dahil olmak üzere  jenkins kullanıcısına aktarıyorum.
```console
jenkins_server@ubuntuserver:~$ sudo chown -R jenkins:jenkins /var/lib/jenkins
```
<br>

Şimdi sıra Jenkins'in config dosyasını ayarlamaya geldi. Bunun için /lib/systemd/system/jenkins.service dosyasını herhangi bir metin düzenleyici aracılığıyla açmalıyım. Bunun için her zamanki gibi vim kullanacağım.
```console
jenkins_server@ubuntuserver:~$ sudo vim /lib/systemd/system/jenkins.service
```
<br>

Eklemem gereken(yorum satırını kaldırmam gereken) satırlar:
```
# Jenkins log dosyasını aktifleştirmek için
Environment="JENKINS_LOG=%L/jenkins/jenkins.log"

# Jenkins'e http üzerinden erişimi kaldırmak için
Environment="JENKINS_PORT=-1"

# Jenkins'e https üzerinden 8443 portu ile erişim sağlamak için
Environment="JENKINS_HTTPS_PORT=8443"

# SSL sertifikasının konumu
Environment="JENKINS_HTTPS_KEYSTORE=/var/lib/jenkins/.ssl/jkeystore.jks"

# SSL sertifikasını oluştururken belirlediğimiz şifre. Evet biliyorum 123456 hiç güvenli bir şifre değil asla ama asla böyle basit bir şifre kullanmamam gerekli bunu da biliyorum :)
Environment="JENKINS_HTTPS_KEYSTORE_PASSWORD=123456"

```
<br>

Değişiklikleri yapıp kaydedip çıkıyorum. Hemen ardından Jenkins'i yeniden başlatmam gerekli.
```console
jenkins_server@ubuntuserver:~$ sudo systemctl daemon-reload
jenkins_server@ubuntuserver:~$ sudo systemctl restart jenkins
```
<br>

Artık Jenkins'e https://localhost:8443 adresinden ulaşmam gerekiyor. http://localhost:8080 adresine gittiğimde ise olması gerektiği gibi boş bir adresle karşılaşıyorum.
<br>

Şimdilik 8080 portunu kullanmayacağım için ileride bana güvenlik açığı oluşturmaması adına bu portu kapatmaya karar verdim.
```console
jenkins_server@ubuntuserver:~$ sudo ufw delete allow 8080
```
<br>

<h1>4. Jenkins Agent Kurulumu</h1>
Jenkins, pipeline aşamalarını uygularken agent kullanımını zorunlu kılmaz fakat iş gücünü parelel çalışan işlemcilere dağıtmak ve çeşitli güvenlik sebeplerinden dolayı agent kurmamız önerilir. Bende bu kurulumda agent kullanmaya karar verdim.
<br><br>

Öncelikle agent kurmak için sol alttan Build Executor Status sekmesine giriyorum.<br>
Oradan solda yer alan "New Node" butonuna tıklayınca yeni node(agent) kurma sekmesi karşılıyor beni. Node name kısmına "agent1" girip Permanent Agent tikini işaretliyorum çünkü kuracağım agentın kalıcı olmasını istiyorum.
<br><br>

Number of executors
```
1
```
<br>

Remote root directory
```
/home/jenkins_agent/agent
```
<br>

Labels
```
linux docker java agent1
```
<br>

Usage
```
Use this node as much as possible
```
<br>

Launch method
```
Launch agents via SSH
```

* Host
  ```
  192.168.1.208
  ```

* Host Key Verification Strategy
  ```
  Known hosts file Verification Strategy
  ```

Availability
```
Keep this agent online as much as possible
```
<br>

Host Key Verification Strategy olarak Known hosts file Verification Strategy seçtiğim için jenkinsin dizinindeki known_hosts dosyasının içine agent ip adresimi girmeliyim.
<br>

Öncelikle known_hosts dosyasını yerleştireceğim .ssh klasörünü oluşturuyorum
```console
jenkins_server@ubuntuserver:~$ sudo mkdir -p /var/lib/jenkins/.ssh
```
<br>

ssh-keyscan aracı yardımıyla known_hosts dosyasını oluşturuyorum
```console
jenkins_server@ubuntuserver:~$ sudo ssh-keyscan -H 192.168.1.208 >> /var/lib/jenkins/.ssh/known_hosts
```
<br>

Oluşturduğum dosyaların sahibi yine root kullanıcısı. Bu dosyaların sahipliğini öncedende yaptığım gibi hemen jenkins kullanıcısına geçiriyorum.
```console
jenkins_server@ubuntuserver:~$ sudo chown -R jenkins:jenkins /var/lib/jenkins
```
<br>

Değişiklikleri aynen yapıp agent1 sunucumu da açtıktan sonra jenkins arayüzünden agent1 nodeuna başarılı bir şekilde güvenli ssh bağlantısı kurduğumu gösteren "Agent successfully connected and online" yazısını görüyorum.

<h1>5. Pipeline Oluşturma</h1>

Jenkins arayüzünde New Item sekmesine girip Pipeline'ı seçip pipelıneıma isim veriyorum.
<br>

Definition
```
Pipeline script from SCM
```

* Repositories<br>
  * Repository URL
    ```
    https://github.com/karakoc49/java-test
    ```
    <br> 

* Branches to build<br>
  * Branch specifier
    ```
    */main
    ```
    <br>

* Script path
  ```
  Jenkinsfile
  ```
  <br>

<h1>6. Docker Socket Yetkisi</h1>

Jenkins konteyner imajı oluşturmak için docker kullanıyor. Bunun için ikinci sunucudaki(jenkins_agent@ubuntuserver) docker socketine(/var/run/docker.sock) erişim izni gerekiyor.
<br>

Bunun için jenkins grubunu ve kullanıcıyı docker grubuna dahil etmem gerekiyor.
```console
jenkins_agent@ubuntuserver:~$ sudo usermod -aG docker jenkins
jenkins_agent@ubuntuserver:~$ sudo usermod -aG docker $USER
```

<h1>7. Eklemek İstediklerim ve Son</h1>
Şu ana kadar başaramadığım tek şey geçerli bir SSL sertifikası bulabilmek oldu. İtiraf etmeliyim ki daha önce çalıştığım sunucuların hiç birinde DNS hizmeti yoktu. Bu yüzden de geçerli bir sertifika ile SSL bağlantı kurmayı başaramadım. DNS hizmeti olan bir sunucu üzerinde çalışırsam çeşitli sertifika hizmetleri ile geçerli bir SSL bağlantısı kurabileceğime inanıyorum.
<br><br>

Bunun dışında yaptığım adımlardan sonra her şeyin mükemmel bir şekilde çalıştığını düşünüyorum ve yaptığım işten her zamanki gibi gurur duyuyorum.