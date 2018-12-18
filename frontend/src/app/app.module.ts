import {BrowserModule} from '@angular/platform-browser';
import {NgModule} from '@angular/core';
import {HttpClientModule} from '@angular/common/http';

import {AppRoutingModule} from './app-routing.module';
import {AppComponent} from './app.component';

import {NgbModule} from '@ng-bootstrap/ng-bootstrap';
import {DataTablesModule} from 'angular-datatables';

import {HeaderComponent} from './header/header.component';
import {OverviewComponent} from './overview/overview.component';
import {SidebarComponent} from './sidebar/sidebar.component';
import {DataService} from './shared/data.service';
import { DetailComponent } from './detail/detail.component';
import {D3_DIRECTIVES, D3Service} from "./d3";
import {GraphComponent} from "./visuals/graph/graph.component";
import {SHARED_VISUALS} from "./visuals/shared";
import { CompilationUnitComponent } from './detail/compilation-unit/compilation-unit.component';
import { DuplicationComponent } from './detail/duplication/duplication.component';


@NgModule({
  declarations: [
    AppComponent,
    HeaderComponent,
    OverviewComponent,
    SidebarComponent,
    DetailComponent,
    GraphComponent,
    ...SHARED_VISUALS,
    ...D3_DIRECTIVES,
    CompilationUnitComponent,
    DuplicationComponent
  ],
  imports: [
    BrowserModule,
    NgbModule,
    HttpClientModule,
    AppRoutingModule,
    DataTablesModule
  ],
  providers: [
    DataService,
    D3Service
  ],
  bootstrap: [AppComponent]
})
export class AppModule {
}
