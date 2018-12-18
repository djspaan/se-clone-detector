import APP_CONFIG from '../../app.config';
import {Router} from "@angular/router";

export class Node implements d3.SimulationNodeDatum {
  // optional - defining optional implementation properties - required for relevant typing assistance
  index?: number;
  x?: number;
  y?: number;
  vx?: number;
  vy?: number;
  fx?: number | null;
  fy?: number | null;

  id: string;
  content: string;
  color: string = 'rgb(0,0,0)';
  router: Router;
  linkCount: number = 0;

  constructor(id, content, color, router) {
    this.id = id;
    this.content = content;
    this.color = color;
    this.router = router;
  }

  normal() {
    return Math.sqrt(this.linkCount / APP_CONFIG.N);
  }

  get r() {
    return 50 * this.normal() + 10;
  }

  get fontSize() {
    return (30 * this.normal() + 10) + 'px';
  }

  clicked() {
    this.router.navigate(['detail', this.id]);
  }

  // get color() {
  //   return this.color;
    // let index = Math.floor(APP_CONFIG.SPECTRUM.length * this.normal());
    // return APP_CONFIG.SPECTRUM[index];
  // }
}
