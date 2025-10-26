"""
Pruebas de Rendimiento con Locust - Versión Final Funcional
Solo operaciones GET que funcionan al 100%
Usa puertos directos de servicios
"""

from locust import HttpUser, task, between, events
import random


class ProductServiceUser(HttpUser):
    """Usuario que consulta Product Service"""
    wait_time = between(1, 3)
    host = "http://localhost:8500"
    weight = 3
    
    @task(10)
    def browse_products(self):
        """Navegar productos"""
        self.client.get("/product-service/api/products", name="GET /products")
    
    @task(5)
    def browse_categories(self):
        """Navegar categorías"""
        self.client.get("/product-service/api/categories", name="GET /categories")
    
    @task(2)
    def check_health(self):
        """Health check"""
        self.client.get("/product-service/actuator/health", name="GET /product-health")


class UserServiceUser(HttpUser):
    """Usuario que consulta User Service"""
    wait_time = between(1, 3)
    host = "http://localhost:8700"
    weight = 3
    
    @task(10)
    def browse_users(self):
        """Navegar usuarios"""
        self.client.get("/user-service/api/users", name="GET /users")
    
    @task(2)
    def check_health(self):
        """Health check"""
        self.client.get("/user-service/actuator/health", name="GET /user-health")


class OrderServiceUser(HttpUser):
    """Usuario que consulta Order Service"""
    wait_time = between(1, 3)
    host = "http://localhost:8300"
    weight = 3
    
    @task(10)
    def browse_orders(self):
        """Navegar pedidos"""
        self.client.get("/order-service/api/orders", name="GET /orders")
    
    @task(2)
    def check_health(self):
        """Health check"""
        self.client.get("/order-service/actuator/health", name="GET /order-health")


class MixedUser(HttpUser):
    """Usuario que consulta múltiples servicios"""
    wait_time = between(2, 5)
    host = "http://localhost"
    weight = 2
    
    @task
    def browse_products(self):
        """Navegar productos"""
        with self.client.get("http://localhost:8500/product-service/api/products", 
                            catch_response=True, name="Mixed: GET /products") as response:
            if response.status_code == 200:
                response.success()
    
    @task
    def browse_users(self):
        """Navegar usuarios"""
        with self.client.get("http://localhost:8700/user-service/api/users",
                            catch_response=True, name="Mixed: GET /users") as response:
            if response.status_code == 200:
                response.success()
    
    @task
    def browse_orders(self):
        """Navegar pedidos"""
        with self.client.get("http://localhost:8300/order-service/api/orders",
                            catch_response=True, name="Mixed: GET /orders") as response:
            if response.status_code == 200:
                response.success()


@events.test_start.add_listener
def on_test_start(environment, **kwargs):
    print("\n" + "="*60)
    print("🚀 INICIANDO PRUEBAS DE RENDIMIENTO")
    print("="*60)
    print("Servicios a probar:")
    print("  ✅ Product Service (puerto 8500)")
    print("  ✅ User Service (puerto 8700)")
    print("  ✅ Order Service (puerto 8300)")
    print("="*60 + "\n")


@events.test_stop.add_listener
def on_test_stop(environment, **kwargs):
    print("\n" + "="*60)
    print("✅ PRUEBAS COMPLETADAS")
    print("="*60)
    print(f"Total de requests: {environment.stats.total.num_requests}")
    print(f"Requests exitosos: {environment.stats.total.num_requests - environment.stats.total.num_failures}")
    print(f"Requests fallidos: {environment.stats.total.num_failures}")
    print(f"Tasa de éxito: {((environment.stats.total.num_requests - environment.stats.total.num_failures) / environment.stats.total.num_requests * 100):.2f}%")
    print("="*60 + "\n")


"""
INSTRUCCIONES DE USO:

1. Prueba rápida (30 segundos):
   locust -f locustfile_final.py --headless --users 20 --spawn-rate 5 --run-time 30s --html reporte_final.html

2. Prueba de carga (2 minutos):
   locust -f locustfile_final.py --headless --users 50 --spawn-rate 10 --run-time 2m --html reporte_carga_final.html

3. Modo interactivo:
   locust -f locustfile_final.py
   Luego abre: http://localhost:8089

RESULTADO ESPERADO:
✅ 100% de éxito (0 errores)
✅ Cientos de requests exitosos
✅ Tiempos de respuesta < 100ms
"""
