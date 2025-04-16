import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  IonTabs,
  IonTabBar,
  IonTabButton,
  IonLabel,
  IonIcon,
} from '@ionic/angular/standalone';
import {
  car,
  bicycle,
  bus,
  boat,
  alertCircleOutline,
  settingsOutline,
} from 'ionicons/icons';
import { addIcons } from 'ionicons';
import { VehicleService } from '../../services/vehicle.service';
import { Vehicle } from '../../models/Vehicle';
import { VehicleTypes } from '../../models/VehicleTypes';
import { Router } from '@angular/router';

@Component({
  selector: 'app-tabs',
  templateUrl: 'tabs.page.html',
  styleUrls: ['tabs.page.scss'],
  imports: [CommonModule, IonTabs, IonTabBar, IonTabButton, IonLabel, IonIcon],
})
export class TabsPage implements OnInit {
  vehicles: Vehicle[] = [];

  constructor(private vehicleService: VehicleService, private router: Router) {
    // Registrar los iconos
    addIcons({
      car: car,
      bicycle: bicycle,
      bus: bus,
      boat: boat,
      alertCircleOutline: alertCircleOutline,
      settingsOutline: settingsOutline,
    });
  }

  ngOnInit() {
    this.vehicles = this.vehicleService.getVehicles();
    if (this.vehicles.length === 0 && this.router.url !== '/settings') {
      this.router.navigate(['/no-vehicles']);
    }
  }

  getVehicleIcon(type: VehicleTypes): string {
    switch (type) {
      case VehicleTypes.Car:
        return 'car';
      case VehicleTypes.Motorcycle:
        return 'bicycle';
      case VehicleTypes.Truck:
        return 'bus';
      case VehicleTypes.Bus:
        return 'bus';
      case VehicleTypes.Bicycle:
        return 'bicycle';
      case VehicleTypes.Scooter:
        return 'bicycle';
      case VehicleTypes.Van:
        return 'car';
      case VehicleTypes.Camper:
        return 'car';
      case VehicleTypes.Motorboat:
        return 'boat';
      case VehicleTypes.Quad:
        return 'car';
      case VehicleTypes.Buggy:
        return 'car';
      default:
        return 'car';
    }
  }
}
