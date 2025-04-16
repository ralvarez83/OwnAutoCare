import { Injectable } from '@angular/core';
import { CanActivate, Router } from '@angular/router';
import { VehicleService } from '../services/vehicle.service';

@Injectable({
  providedIn: 'root',
})
export class VehicleGuard implements CanActivate {
  constructor(private vehicleService: VehicleService, private router: Router) {}

  canActivate(): boolean {
    const vehicles = this.vehicleService.getVehicles();
    if (vehicles.length > 0) {
      this.router.navigate(['/vehicle', vehicles[0].id]);
    } else {
      this.router.navigate(['/no-vehicles']);
    }
    return false;
  }
}
