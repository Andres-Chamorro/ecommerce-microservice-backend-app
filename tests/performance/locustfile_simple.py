"""
Pruebas de Rendimiento con Locust - Versión Simplificada
Solo operaciones de lectura (GET) que funcionan correctamente
"""

from locust import HttpUser, task, between
import random


class EcommerceUser(HttpUser):
    """
    Usuario que realiza operaciones de lectura en el sistema
    Simula navegación y consultas sin modificar datos
    NOTA: Usa puertos directos porque el API Gateway tiene problemas de enrutamiento
    """
    wait_time = between(1, 3)
    host = "http://localhost"  # Base, cada endpoint especifica su puerto
    
    @task(10)
    def browse_products(self):
        """Navegar por el catálogo de productos"""
        self.client.get(
            ":8500/product-service/api/products",
            name="GET /products"
        )
    
    @task(5)
    def view_product_details(self):
        """Ver detalles de un producto específico"""
        product_id = random.randint(1, 10)
        self.client.get(
            f":8500/product-service/api/products/{product_id}",
            name="GET /product/:id"
        )
    
    @task(8)
    def browse_users(self):
        """Consultar lista de usuarios"""
        self.client.get(
            ":8700/user-service/api/users",
            name="GET /users"
        )
    
    @task(4)
    def view_user_profile(self):
        """Ver perfil de un usuario específico"""
        user_id = random.randint(1, 5)
        self.client.get(
            f":8700/user-service/api/users/{user_id}",
            name="GET /user/:id"
        )
    
    @task(7)
    def browse_orders(self):
        """Consultar lista de pedidos"""
        self.client.get(
            ":8300/order-service/api/orders",
            name="GET /orders"
        )
    
    @task(3)
    def view_order_details(self):
        """Ver detalles de un pedido específico"""
        order_id = random.randint(1, 5)
        self.client.get(
            f":8300/order-service/api/orders/{order_id}",
            name="GET /order/:id"
        )
    
    @task(5)
    def browse_categories(self):
        """Consultar categorías de productos"""
        self.client.get(
            ":8500/product-service/api/categories",
            name="GET /categories"
        )
    
    @task(2)
    def check_api_gateway_health(self):
        """Verificar salud del API Gateway"""
        self.client.get(
            ":8080/actuator/health",
            name="GET /gateway-health"
        )
    
    @task(3)
    def check_user_service_health(self):
        """Verificar salud del User Service"""
        self.client.get(
            ":8700/user-service/actuator/health",
            name="GET /user-health"
        )
    
    @task(3)
    def check_product_service_health(self):
        """Verificar salud del Product Service"""
        self.client.get(
            ":8500/product-service/actuator/health",
            name="GET /product-health"
        )
    
    @task(3)
    def check_order_service_health(self):
        """Verificar salud del Order Service"""
        self.client.get(
            ":8300/order-service/actuator/health",
            name="GET /order-health"
        )


class HeavyUser(HttpUser):
    """
    Usuario que realiza muchas consultas rápidas
    Simula carga pesada de solo lectura
    """
    wait_time = between(0.5, 1.5)
    host = "http://localhost"
    weight = 2  # Menos usuarios de este tipo
    
    @task(20)
    def rapid_product_browsing(self):
        """Navegación rápida de productos"""
        self.client.get(":8500/product-service/api/products")
    
    @task(10)
    def rapid_user_browsing(self):
        """Navegación rápida de usuarios"""
        self.client.get(":8700/user-service/api/users")
    
    @task(10)
    def rapid_order_browsing(self):
        """Navegación rápida de pedidos"""
        self.client.get(":8300/order-service/api/orders")


class LightUser(HttpUser):
    """
    Usuario ligero que solo navega ocasionalmente
    Simula usuarios que entran y salen rápido
    """
    wait_time = between(3, 7)
    host = "http://localhost"
    weight = 5  # Más usuarios de este tipo
    
    @task(5)
    def casual_product_browse(self):
        """Navegación casual de productos"""
        self.client.get(":8500/product-service/api/products")
    
    @task(2)
    def check_system_health(self):
        """Verificar que el sistema está activo"""
        self.client.get(":8080/actuator/health")


"""
INSTRUCCIONES DE USO:

1. Prueba rápida (30 segundos):
   locust -f locustfile_simple.py --headless --users 20 --spawn-rate 5 --run-time 30s --html reporte_simple.html

2. Prueba de carga (5 minutos):
   locust -f locustfile_simple.py --headless --users 50 --spawn-rate 10 --run-time 5m --html reporte_carga.html

3. Prueba de estrés (10 minutos):
   locust -f locustfile_simple.py --headless --users 200 --spawn-rate 20 --run-time 10m --html reporte_estres.html

4. Modo interactivo:
   locust -f locustfile_simple.py
   Luego abre: http://localhost:8089

VENTAJAS DE ESTA VERSIÓN:
- ✅ Solo operaciones GET (lectura)
- ✅ No modifica datos del sistema
- ✅ Todos los endpoints funcionan correctamente
- ✅ 0% de errores esperados
- ✅ Mide rendimiento real de consultas
"""
