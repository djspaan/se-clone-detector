import {Component, OnDestroy, OnInit} from '@angular/core';
import {Subject} from "rxjs/internal/Subject";
import {CompilationUnit} from "../shared/compilation-unit";
import {DataService} from "../shared/data.service";
import {Duplication} from "../shared/duplication";

@Component({
  selector: 'app-statistics',
  templateUrl: './statistics.component.html',
  styleUrls: ['./statistics.component.scss']
})
export class StatisticsComponent implements OnInit, OnDestroy {
  dtTrigger: Subject<any> = new Subject();
  classes: CompilationUnit[] = [];
  duplications: Duplication[] = [];

  constructor(private dataService: DataService) { }

  ngOnInit() {
    this.dataService.getDuplications().subscribe(dups => this.duplications = dups);
    this.dataService.dataUnit.subscribe(classes => {
      this.classes = classes;
      this.dtTrigger.next();
    });
  }

  ngOnDestroy() {
    this.dtTrigger.unsubscribe();
  }

  getPercentageDuplicatedLines(): number {
    if (!this.classes.length) return 0;
    let result = 0;
    for (let c of this.classes) {
      result += c.getDuplicatePercentage();
    }
    return +(result / this.classes.length).toFixed(2);
  }

  getNumberOfClones(): number {
    return this.duplications.length;
  }

  getBiggestClone(): Duplication|null {
    if (!this.duplications.length) return null;
    let highest = this.duplications[0];
    for (let d of this.duplications) {
      if (d.locs[0].length > highest.locs[0].length) highest = d;
    }
    return highest;
  }

  getBiggestCloneClass(): CompilationUnit|null {
    if (!this.classes.length) return null;
    let highest = this.classes[0];
    for (let c of this.classes) {
      if (c.duplications.length > highest.duplications.length) highest = c;
    }
    return highest;
  }

}
