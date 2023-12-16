# infrastructure

![Örnek Resim](https://github.com/Cantooine/infrastructure/blob/master/diagram.png)
## Giriş
Bu repo, Terraform ile AWS üzerinde highly available ve scalable bir web uygulaması altyapısının nasıl kurulabileceğine örnek teşkil etmektedir. Uygulama, frontend ve backend bileşenlerinden oluşmaktadır. Bileşenler ECS(Elastic Container Service) üzerinde çalışmaktadır. Ayrıca örnek autoscaling konfigürasyonlarına sahiptirler. İki bileşen de private subnetlere dağıtılmıştır. Frontend servisi external bir load balancer üzerinden internete açılmış, backend servisi internal bir load balancer ile private subnetlerden trafik kabul etmektedir.

## Önkoşullar
* AWS Hesabı
* Terraform kurulumu
* AWS CLI kurulumu ve yapılandırılması

## Özet
**VPC ve Subnetler**: Proje için bir VPC (10.0.0.0/16) ve bu VPC'de hem private hem de public subnetler oluşturulur.

**Internet Gateway (IGW) ve NAT Gateway**: Public subnetler için bir IGW ve private subnetlerin her availablity zone'u için ayrı bir NAT Gateway oluşturulur.

**Route Table'lar**: Public subnetler için bir, private subnetler için AZ sayısı kadar route table tanımlanır. Public subnetler IGW üzerinden internete çıkış yaparken, private subnetler kendi AZ'lerindeki NAT Gateway üzerinden internete çıkış yaparlar.

**Security Group'lar**: Frontend ve backend ECS servislerinin security group'ları kendi load balancer'larının bulunduğu subnetlerden trafik kabul edecek şekilde ayarlanır(Frontend public subnetlerden, backend private subnetlerden). Frontend load balancer'ının security group'u internetten trafik alabilecek şekilde, backend load balancer'ının security group'u private subnetlerden trafik alabilecek şekilde ayarlanır.

**ECS Cluster, Task Definition ve Service**: Bir ECS cluster ve her servis için task definition ve service oluşturulur.

**Application Load Balancer (ALB)**: Trafik yönlendirme ve yük dengeleme için hem internal (backend için) hem de external (frontend için) ALB'ler oluşturulur. ECS servislerinin target group'ları oluşturulur ve bu load balancer'lara attach edilir.

## Kurmak İçin

`git clone https://github.com/cantooine/infrastructure`

`cd infrastructure`

`terraform init`

`terraform plan`

`terraform apply`

## Silmek İçin

`terraform destroy`

## Detaylar

Subnet CIDR'ları maksimum IP alabilecek şekilde ayarlanmıştır. Bu ileriye dönük scale olma halinde IP tükenmesi durumundan korunabilmek içindir.

Her AZ için, bir NAT Gateway oluşturulmuştur. Bu yapı AZ'leri birbirinden izole eder. Bir AZ'de sorun olması veya bir AZ'nin route table'ında sorunlu bir konfigürasyon yapılması durumunda, diğer AZ'ler bundan etkilenmez ve internete bağlantıları kesilmez. Bu tercih projeden projeye değişebilmekle birlikte, highly available olmanın hayati olduğu projelerde en az iki NAT Gateway konfigüre etmek önemlidir.

Backend ECS servisi private subnetlerde çalışmakta olduğundan, IP filtering yapan external kaynaklara erişebilmesi için NAT Gateway'in dışarı çıkan IP adreslerini ilgili yetkililere beyan etmek yeterli olacaktır.

Frontend, backend ile internal load balancer üzerinden iletişim kurar. Service discovery'e kıyasla bu implementasyonun yük dengeleme, health check ve otomatik yönlendirme gibi bazı avantajları olur. Bu avantajlar high availability'e ve fault tolerance'a katkıda bulunur.

ECS servisleri için autoscaling ayarlanmıştır. Bu scalablity'nin sağlanmasını gözetir. Projenin ihtiyacına göre scaling ayarları Terraform üzerinden yapılandırılabilir.

ECS servisleri FARGATE ile çalıştırılmaktadır. FARGATE, EC2'ya kıyasla cost-effective ve yönetimi kolay bir çözümdür (FARGATE'de kullanılan kadar ödenirken, EC2'da devamlı ödeme gerekmektedir).

Proje PoC(Proof of Concept) niteliğinde olduğundan, gerçek senaryo kullanımına uygun değildir. Terraform state (tfstate) dosyasının nerede ve nasıl saklanacağını ayarlamak, birden fazla kişinin çalıştığı projelerde state lock mekanizması oluşturmak, ihtiyaca göre ALB'ler için WAF ve SSL yapılandırmaları yapmak önemlidir.
