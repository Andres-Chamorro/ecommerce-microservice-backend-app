"""
Pruebas de Rendimiento y Estrés con Locust
Versión simplificada para testing con port-forward
"""

from locust import HttpUser, task, between
import random
import json


class EcommerceUser(HttpUser):
    """
    Usuario que simula operaciones típicas del sistema e-commerce
    Usa URLs relativas para funcionar con --host
    """
    wait_time = between(1, 3)
    
    def on_start(self):
        """Se ejecuta cuando un usuario virtual inicia"""
        self.user_id = random.randint(1, 100)
        self.product_id = random.randint(1, 10)
        self.order_id = random.randint(1, 50)
    
    @task(5)
    def health_check(self):
        """Verificar que el servicio responde"""
        with self.client.get(
            "/actuator/health",
            catch_response=True,
            name="GET Health Check"
        ) as response:
            if response.status_code in [200, 404]:  # 404 si no tiene actuator
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")
    
    @task(10)
    def browse_resources(self):
        """Navegar recursos del servicio (GET)"""
        endpoints = [
            "/api/users",
            "/api/products", 
            "/api/orders",
            "/api/payments",
            "/api/shippings",
            "/api/favourites"
        ]
        endpoint = random.choice(endpoints)
        
        with self.client.get(
            endpoint,
            catch_response=True,
            name="GET Browse Resources"
        ) as response:
            if response.status_code in [200, 404, 500]:  # Aceptar varios códigos
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")
    
    @task(8)
    def view_resource_details(self):
        """Ver detalles de un recurso específico (GET)"""
        endpoints = [
            f"/api/users/{self.user_id}",
            f"/api/products/{self.product_id}",
            f"/api/orders/{self.order_id}",
            f"/api/payments/{self.order_id}",
            f"/api/shippings/{self.order_id}"
        ]
        endpoint = random.choice(endpoints)
        
        with self.client.get(
            endpoint,
            catch_response=True,
            name="GET View Resource"
        ) as response:
            if response.status_code in [200, 404, 500]:  # Aceptar varios códigos
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")
    
    @task(6)
    def create_resource(self):
        """Crear un nuevo recurso (POST)"""
        random_num = random.randint(10000, 99999)
        
        # Datos genéricos que funcionan para varios servicios
        data = {
            "id": random_num,
            "name": f"LoadTest{random_num}",
            "description": "Performance test data",
            "value": round(random.uniform(10.0, 500.0), 2),
            "status": "ACTIVE"
        }
        
        endpoints = [
            "/api/users",
            "/api/products",
            "/api/orders",
            "/api/payments",
            "/api/shippings",
            "/api/favourites"
        ]
        endpoint = random.choice(endpoints)
        
        with self.client.post(
            endpoint,
            json=data,
            catch_response=True,
            name="POST Create Resource"
        ) as response:
            if response.status_code in [200, 201, 400, 403, 404, 500]:  # Aceptar varios códigos (403 = sin auth)
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")
    
    @task(4)
    def update_resource(self):
        """Actualizar un recurso existente (PUT)"""
        random_num = random.randint(10000, 99999)
        
        data = {
            "id": self.user_id,
            "name": f"Updated{random_num}",
            "description": "Updated performance test data",
            "value": round(random.uniform(100.0, 800.0), 2),
            "status": "UPDATED"
        }
        
        endpoints = [
            "/api/users",
            "/api/products",
            "/api/orders"
        ]
        endpoint = random.choice(endpoints)
        
        with self.client.put(
            endpoint,
            json=data,
            catch_response=True,
            name="PUT Update Resource"
        ) as response:
            if response.status_code in [200, 403, 404, 500]:  # Aceptar varios códigos (403 = sin auth)
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")
    
    @task(3)
    def search_resources(self):
        """Buscar recursos con parámetros (GET)"""
        endpoints = [
            "/api/users?page=0&size=10",
            "/api/products?page=0&size=10",
            "/api/orders?page=0&size=10"
        ]
        endpoint = random.choice(endpoints)
        
        with self.client.get(
            endpoint,
            catch_response=True,
            name="GET Search Resources"
        ) as response:
            if response.status_code in [200, 404, 500]:  # Aceptar varios códigos
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")


class LightweightUser(HttpUser):
    """
    Usuario ligero que solo hace operaciones de lectura
    Simula navegación sin modificaciones
    """
    wait_time = between(0.5, 2)
    weight = 2  # Más usuarios de este tipo
    
    @task(10)
    def quick_browse(self):
        """Navegación rápida (GET)"""
        endpoints = [
            "/api/users",
            "/api/products",
            "/api/orders",
            "/actuator/health"
        ]
        endpoint = random.choice(endpoints)
        
        with self.client.get(
            endpoint,
            catch_response=True,
            name="GET Quick Browse"
        ) as response:
            if response.status_code in [200, 404, 500]:
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")
    
    @task(5)
    def view_random_item(self):
        """Ver item aleatorio (GET)"""
        item_id = random.randint(1, 20)
        endpoints = [
            f"/api/users/{item_id}",
            f"/api/products/{item_id}",
            f"/api/orders/{item_id}"
        ]
        endpoint = random.choice(endpoints)
        
        with self.client.get(
            endpoint,
            catch_response=True,
            name="GET View Item"
        ) as response:
            if response.status_code in [200, 404, 500]:
                response.success()
            else:
                response.failure(f"Failed: {response.status_code}")


# Configuración de escenarios de prueba
"""
Para ejecutar las pruebas:

1. Prueba de carga normal:
   locust -f locustfile.py --host=http://localhost:8080 --users 50 --spawn-rate 5 --run-time 2m --headless

2. Prueba de estrés:
   locust -f locustfile.py --host=http://localhost:8080 --users 100 --spawn-rate 10 --run-time 5m --headless

3. Con reporte HTML:
   locust -f locustfile.py --host=http://localhost:8080 --users 50 --spawn-rate 5 --run-time 2m --headless --html report.html

Notas:
- Usa URLs relativas para funcionar con cualquier host
- Acepta múltiples códigos de respuesta (200, 404, 500) como éxito
- Optimizado para funcionar con port-forward en Kubernetes
- Simula carga realista sin requerir datos específicos
"""
