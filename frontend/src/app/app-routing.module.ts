import { NgModule } from '@angular/core';
import { Routes, RouterModule } from '@angular/router';

import {OverviewComponent} from './overview/overview.component';
import {DetailComponent} from './detail/detail.component';
import {NotFoundComponent} from "./not-found/not-found.component";

const routes: Routes = [
  {path: '', redirectTo: '/overview', pathMatch: 'full'},
  {path: 'overview', component: OverviewComponent},
  {path: 'detail/:uri', component: DetailComponent},
  {path: '**', component: NotFoundComponent}
];

@NgModule({
  imports: [RouterModule.forRoot(routes)],
  exports: [RouterModule]
})
export class AppRoutingModule { }
