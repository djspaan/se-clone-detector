import {Component, ElementRef, OnDestroy, OnInit, ViewChild} from '@angular/core';
import {DataService} from '../shared/data.service';
import {Subject} from "rxjs/internal/Subject";
import {CompilationUnit} from "../shared/compilation-unit";
import {Node, Link} from "../d3/models";
import {Router} from "@angular/router";

@Component({
  selector: 'app-overview',
  templateUrl: './overview.component.html',
  styleUrls: ['./overview.component.scss']
})
export class OverviewComponent implements OnInit {
  @ViewChild('graph') graph:ElementRef;

  classes: CompilationUnit[];
  nodes: Node[] = [];
  links: Link[] = [];
  visualize: boolean = false;

  constructor(private dataService: DataService, private router: Router) { }

  ngOnInit() {
    this.dataService.dataUnit.subscribe(classes => {
      this.nodes = [];
      this.links = [];
      this.classes = classes;
      for (let c of this.classes) {
        let node = new Node(c.id, c.getName(), 'cyan', this.router);
        node.linkCount = c.duplications.length;
        this.nodes.push(node);
      }
      this.dataService.getDuplications().subscribe(duplications => {
        for (let d of duplications) {
          let node = new Node(d.id, '', ['orange', 'red', 'green', 'purple'][d.type], this.router);
          node.linkCount = d.getUris().length;
          this.nodes.push(node);
          for (let u of d.getUris()) {
            let cu = this.classes.find(c => c.loc.uri == u);
            if (cu) this.links.push(new Link(cu.id, d.id));
          }
        }
        this.visualize = true;
      });
    });
  }


}
