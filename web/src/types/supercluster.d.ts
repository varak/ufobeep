declare module 'supercluster' {
  interface SuperclusterOptions {
    radius?: number;
    maxZoom?: number;
    minPoints?: number;
    extent?: number;
    nodeSize?: number;
    log?: boolean;
    generateId?: boolean;
    reduce?: (accumulated: any, props: any) => void;
    map?: (props: any) => any;
  }

  interface SuperclusterCluster {
    type: 'Feature';
    id: number;
    properties: {
      cluster: true;
      cluster_id: number;
      point_count: number;
      point_count_abbreviated: number | string;
    };
    geometry: {
      type: 'Point';
      coordinates: [number, number];
    };
  }

  interface SuperclusterPoint {
    type: 'Feature';
    properties: any;
    geometry: {
      type: 'Point';
      coordinates: [number, number];
    };
  }

  export default class Supercluster {
    constructor(options?: SuperclusterOptions);
    load(points: SuperclusterPoint[]): this;
    getClusters(bbox: [number, number, number, number], zoom: number): (SuperclusterCluster | SuperclusterPoint)[];
    getChildren(clusterId: number): (SuperclusterCluster | SuperclusterPoint)[];
    getLeaves(clusterId: number, limit?: number, offset?: number): SuperclusterPoint[];
    getTile(z: number, x: number, y: number): {
      features: (SuperclusterCluster | SuperclusterPoint)[];
    };
    getClusterExpansionZoom(clusterId: number): number;
  }
}