import {Component, OnDestroy, OnInit} from '@angular/core';
import {DataService} from '../shared/data.service';
import {Subject} from "rxjs/internal/Subject";
import {CompilationUnit} from "../shared/compilation-unit";
import {Node, Link} from "../d3/models";

@Component({
  selector: 'app-overview',
  templateUrl: './overview.component.html',
  styleUrls: ['./overview.component.scss']
})
export class OverviewComponent implements OnInit, OnDestroy {
  dtTrigger: Subject<any> = new Subject();
  classes: CompilationUnit[];
  nodes: Node[] = [];
  links: Link[] = [];
  visualize: boolean = false;

  constructor(private dataService: DataService) { }

  ngOnInit() {
    this.dataService.dataUnit.subscribe(classes => {
      this.classes = classes;
      this.dtTrigger.next();
      for (let c of this.classes) {
        let node = new Node(c.id, c.getName(), 'blue');
        node.linkCount = c.duplications.length;
        this.nodes.push(node);
      }
      this.dataService.getDuplications().subscribe(duplications => {
        for (let d of duplications) {
          let node = new Node(d.id, '', 'purple');
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

    //
    // const N = APP_CONFIG.N,
    //   getIndex = number => number - 1;
    //
    // /** constructing the nodes array */
    // for (let i = 1; i <= N; i++) {
    //   this.nodes.push(new Node(i));
    // }
    //
    // for (let i = 1; i <= N; i++) {
    //   for (let m = 2; i * m <= N; m++) {
    //     /** increasing connections toll on connecting nodes */
    //     this.nodes[getIndex(i)].linkCount++;
    //     this.nodes[getIndex(i * m)].linkCount++;
    //
    //     /** connecting the nodes before starting the simulation */
    //     this.links.push(new Link(i, i * m));
    //   }
    // }
  }

  ngOnDestroy() {
    this.dtTrigger.unsubscribe();
  }
}
