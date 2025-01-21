import { Component, OnInit } from '@angular/core';
import { ActivatedRoute } from '@angular/router';
import { VehicleService } from '../../services/vehicle.service';
import { Vehicle } from '../../models/Vehicle';

@Component({
  selector: 'app-vehicle-detail',
  templateUrl: './vehicle-detail.component.html',
  styleUrls: ['./vehicle-detail.component.scss'],
})
export class VehicleDetailComponent implements OnInit {
  vehicle: Vehicle | any;

  constructor(
    private route: ActivatedRoute,
    private vehicleService: VehicleService
  ) {}

  ngOnInit() {
    const idParam = this.route.snapshot.paramMap.get('id');
    const vehicleId = idParam ? +idParam : null;
    this.vehicle = this.vehicleService
      .getVehicles()
      .find((v) => v.id === vehicleId);
  }
}
