import {EventEmitter, OnDestroy} from '@angular/core';
import { Link } from './link';
import { Node } from './node';
import * as d3 from 'd3';

const FORCES = {
  LINKS: 1,
  COLLISION: 1,
  CHARGE: -1,
  GROUPING: 0.01
};

export class ForceDirectedGraph{
  public ticker: EventEmitter<d3.Simulation<Node, Link>> = new EventEmitter();
  public simulation: d3.Simulation<any, any>;

  public nodes: Node[] = [];
  public links: Link[] = [];
  private classesFixed = true;

  constructor(nodes, links, options: { width, height }) {
    this.nodes = nodes;
    this.links = links;

    this.initSimulation(options);
  }

  connectNodes(source, target) {
    let link;

    if (!this.nodes[source] || !this.nodes[target]) {
      throw new Error('One of the nodes does not exist');
    }

    link = new Link(source, target);
    this.simulation.stop();
    this.links.push(link);
    this.simulation.alphaTarget(0.3).restart();

    this.initLinks();
  }

  initNodes(options: {width: number, height: number}) {
    if (!this.simulation) {
      throw new Error('simulation was not initialized yet');
    }
    for(let node of this.nodes){
      node.x = Math.random() * options.width;
      node.y = Math.random() * options.height;
    }

    this.simulation.nodes(this.nodes);
  }

  initLinks() {
    if (!this.simulation) {
      throw new Error('simulation was not initialized yet');
    }

    this.simulation.force('links',
      d3.forceLink(this.links)
        .id(d => d['id'])
        .strength(FORCES.LINKS)
        .distance((d) => ((<Node>d.source).r + (<Node>d.target).r) * 1.6)
    );
  }

  initSimulation(options) {
    if (!options || !options.width || !options.height) {
      throw new Error('missing options when initializing simulation');
    }

    /** Creating the simulation */
    if (!this.simulation) {
      const ticker = this.ticker;
      const collisionForce = d3.forceCollide().strength(0).radius(d => d['r'] + 5).iterations(2);

      this.simulation = d3.forceSimulation()
        .force('charge',
          d3.forceManyBody()
            .strength(d => FORCES.CHARGE * d['r'])
        )
        .force('collide',
          collisionForce
        )
        .force('radial',
            d3.forceRadial(options.height, options.width / 2, options.height / 2)
              .strength((d: Node) => d.id.startsWith("cu") ? FORCES.GROUPING : 0)
        );
      const nodes = this.nodes;
      const t0 = Date.now();
      // Connecting the d3 ticker to an angular event emitter
      this.simulation.on('tick', function () {
        ticker.emit(this);
        collisionForce.strength((500 - 500 / (Date.now() - t0)) * (1/1000) * FORCES.COLLISION);
      });

      this.initNodes(options);
      this.initLinks();
    }

    /** Updating the central force of the simulation */
    this.simulation.force('centers', d3.forceCenter(options.width / 2, options.height / 2));

    /** Restarting the simulation internal timer */
    this.simulation.restart();
  }

  fixClasses(){
    if(!this.classesFixed){
      for(let node of this.nodes){
        if(node.id.startsWith("cu")){
          node.fx = node.x;
          node.fy = node.y;
        }
      }
    }
    else{
      for(let node of this.nodes){
        if(node.id.startsWith("cu")){
          node.fx = null;
          node.fy = null;
        }
      }
    }
    this.classesFixed = !this.classesFixed;
  }
}
