import {Loc} from './loc';

export class Duplication {
  id: string;
  type: number;
  weight: number;
  locs: Loc[];

  constructor(id: string, type: number, weight: number, locs: Loc[]) {
    this.id = id;
    this.type = type;
    this.weight = weight;
    this.locs = locs;
  }

  getUris(): string[] {
    return this.locs.map(l => l.uri);
  }
}
