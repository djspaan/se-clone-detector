import {Component, OnDestroy, OnInit} from '@angular/core';
import {DataService} from '../shared/data.service';
import {Subject} from "rxjs/internal/Subject";
import {CompilationUnit} from "../shared/compilation-unit";

@Component({
  selector: 'app-overview',
  templateUrl: './overview.component.html',
  styleUrls: ['./overview.component.scss']
})
export class OverviewComponent implements OnInit, OnDestroy {
  dtTrigger: Subject<any> = new Subject();
  classes: CompilationUnit[];

  constructor(private dataService: DataService) { }

  ngOnInit() {
    this.dataService.dataUnit.subscribe(classes => {
      this.classes = classes;
      this.dtTrigger.next();
    });
  }

  ngOnDestroy() {
    this.dtTrigger.unsubscribe();
  }
}
