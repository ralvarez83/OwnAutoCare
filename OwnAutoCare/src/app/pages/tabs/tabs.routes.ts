import { Routes } from '@angular/router';
import { TabsPage } from './tabs.page';
import { NoVehiclesComponent } from '../../components/no-vehicles/no-vehicles.component';

import { VehicleDetailComponent } from '../../components/vehicle-detail/vehicle-detail.component';
import { SettingsComponent } from '../settings/settings.component';
import { VehicleGuard } from 'src/app/guards/vehicle.guard';
import { AuthGuard } from 'src/app/guards/auth.guard';

export const routes: Routes = [
  {
    path: '',
    component: TabsPage,
    children: [
      {
        path: 'vehicle/:id',
        component: VehicleDetailComponent,
        pathMatch: 'full',
        canActivate: [VehicleGuard],
      },
      {
        path: 'settings',
        component: SettingsComponent,
      },
      {
        path: 'no-vehicles',
        component: NoVehiclesComponent,
        canActivate: [AuthGuard],
      },
      // {
      //   path: 'tab1',
      //   loadChildren: () => import('../tab1/tab1.module').then(m => m.Tab1PageModule)
      // }
      // Agrega más rutas según sea necesario
    ],
  },
];
