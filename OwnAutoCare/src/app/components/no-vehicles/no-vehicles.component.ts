import { Component, OnInit } from '@angular/core';
import { IonContent, IonIcon, IonButton } from '@ionic/angular/standalone';
import { addIcons } from 'ionicons';

import { car, bicycle, bus, boat, alertCircleOutline } from 'ionicons/icons';

@Component({
  selector: 'app-no-vehicles',
  templateUrl: './no-vehicles.component.html',
  styleUrls: ['./no-vehicles.component.scss'],
  imports: [IonContent, IonIcon, IonButton],
})
export class NoVehiclesComponent implements OnInit {
  constructor() {}

  ngOnInit() {
    // Registrar los iconos
    addIcons({
      car: car,
      bicycle: bicycle,
      bus: bus,
      boat: boat,
      alertCircleOutline: alertCircleOutline,
    });
  }
}
