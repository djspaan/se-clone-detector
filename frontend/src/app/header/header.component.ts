import { Component, OnInit } from '@angular/core';
import {DataService} from "../shared/data.service";
import {Router} from "@angular/router";

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.scss']
})
export class HeaderComponent implements OnInit {
  projects: string[] = [];

  constructor(private router: Router, private dataService: DataService) { }

  ngOnInit() {
    this.dataService.getProjects().subscribe(projects => {
      this.projects = projects;
    });
  }

  onAnalyze(project: string) {
    this.dataService.project = project;
    this.dataService.init();
    this.router.navigate(['not-found']);
    this.router.navigate(['/']);
  }
}
