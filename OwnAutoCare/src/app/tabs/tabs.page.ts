import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import {
  IonTabs,
  IonTabBar,
  IonTabButton,
  IonLabel,
  IonIcon,
  IonContent,
} from '@ionic/angular/standalone';
import { car, bicycle, bus, boat } from 'ionicons/icons';
import { addIcons } from 'ionicons';
import { VehicleService } from '../services/vehicle.service';
import { Vehicle } from '../models/Vehicle';
import { VehicleTypes } from '../models/VehicleTypes';

@Component({
  selector: 'app-tabs',
  templateUrl: 'tabs.page.html',
  styleUrls: ['tabs.page.scss'],
  imports: [
    CommonModule,
    IonTabs,
    IonTabBar,
    IonTabButton,
    IonLabel,
    IonIcon,
    IonContent,
  ],
})
export class TabsPage implements OnInit {
  vehicles: Vehicle[] = [];

  constructor(private vehicleService: VehicleService) {
    // Registrar los iconos
    addIcons({
      car: car,
      bicycle: bicycle,
      bus: bus,
      boat: boat,
    });
  }

  ngOnInit() {
    this.vehicles = this.vehicleService.getVehicles();
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
