import { Component, OnInit } from '@angular/core';
import {DataService} from "../../shared/data.service";
import {Subject} from "rxjs/internal/Subject";
import {ActivatedRoute, ParamMap, Router} from "@angular/router";
import {filter, map, switchMap} from "rxjs/operators";
import {Duplication} from "../../shared/duplication";
import {CompilationUnit} from "../../shared/compilation-unit";

@Component({
  selector: 'app-duplication',
  templateUrl: './duplication.component.html',
  styleUrls: ['./duplication.component.scss']
})
export class DuplicationComponent implements OnInit {
  duplication: Duplication;
  clones: CompilationUnit[] = [];
  visualize: boolean = false;

  constructor(private route: ActivatedRoute, private dataService: DataService) { }

  ngOnInit() {
    this.route.paramMap.pipe(
      switchMap((params: ParamMap) => this.dataService.duById(params.get('uri')))
    ).subscribe(d => {
      this.duplication = d;
      this.dataService.dataUnit.pipe(
        map(cus => {
          return cus.filter(cu => this.duplication.getUris().indexOf(cu.loc.uri) >= 0);
        })
      ).subscribe(cus => {
        this.clones = cus;
        this.visualize = true;
      });
    });
  }
}
