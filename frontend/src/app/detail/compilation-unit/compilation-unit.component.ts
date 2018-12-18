import { Component, OnInit } from '@angular/core';
import {DataService} from "../../shared/data.service";
import {ActivatedRoute, ParamMap, Router} from "@angular/router";
import {CompilationUnit} from "../../shared/compilation-unit";
import {switchMap} from "rxjs/operators";

@Component({
  selector: 'app-compilation-unit',
  templateUrl: './compilation-unit.component.html',
  styleUrls: ['./compilation-unit.component.scss']
})
export class CompilationUnitComponent implements OnInit {
  class: CompilationUnit;

  constructor(private route: ActivatedRoute, private router: Router, private dataService: DataService) { }

  ngOnInit() {
    this.route.paramMap.pipe(
      switchMap((params: ParamMap) => this.dataService.cuById(params.get('uri')))
    ).subscribe(c => {
      this.class = c;
    });
  }

}
