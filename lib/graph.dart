/*
  This source file contains and implementation of a simple undirected graph.
  The graph is implemented as an adjacency matrix.
  Vertices are primarily uniquely identified by their labels.
  Edges are ID'd by their sources and destinations, but may also have labels.
*/

class Graph<vLType, eLType> {
  List<vLType> vertexList = []; // ordered list of all vertices
  List<List<eLType?>> adjacencyMatrix = List<List<eLType?>>.empty(growable: true); // the adjacency matrix

  Graph(); // unnamed, parameterless default constructor

  // A constructor to deep copy from another object
  Graph.from(Graph<vLType, eLType> source) {
    this.vertexList = List<vLType>.from(source.vertexList);
    this.adjacencyMatrix = List<List<eLType>>.from(source.adjacencyMatrix);
  }

  // Method to check if graph is empty (no vertices)
  bool isEmpty() {
    return vertexList.isEmpty;
  }

  // Method to check if graph is NULL Graph (no edges, but may have vertices)
  bool isNull() {
    for (final row in this.adjacencyMatrix) {
      for (final thing in row) {
        if (thing != null) {
          return false;
        }
      }
    }
    return true;
  }

  // Method to insert vertex
  // Duplicated vertices not allowed.
  // If vertex is already present, no insertion will be done.
  // Returns -1 if a vertex is already present, 0 otherwise.
  int insertVertex(vLType vertexLabel) {
    if (this.vertexList.contains(vertexLabel)) {
      return -1;
    } else {
      this.vertexList.add(vertexLabel);
      for (final row in this.adjacencyMatrix) {
        row.add(null);
      }
      this.adjacencyMatrix.add(List<eLType?>.generate(vertexList.length, (index) => null));
      return 0;
    }
  }

  // Following function inserts an edge between vertices 'to' and 'from'
  // If edge already exists between them, its label is overwritten
  // If any or both vertices are not present, they are inserted first.
  int insertEdge(vLType from, vLType to, eLType edgeLabel) {

    // Searching for 'to' and 'from' vertices and inserting them if reqd.
    int toIndex = this.vertexList.indexOf(to), fromIndex = this.vertexList.indexOf(from);
    if (toIndex == -1) {
      this.insertVertex(to);
      toIndex = this.vertexList.length - 1;
    }
    if (fromIndex == -1) {
      this.insertVertex(from);
      fromIndex = this.vertexList.length - 1;
    }

    this.adjacencyMatrix[fromIndex][toIndex] = edgeLabel;
    return 0;
  }

  // Method to remove a vertex
  // Returns 0 if successfully removed.
  // Returns -1 if vertex not present.
  int removeVertex(vLType vertexLabel) {
    int removeeIndex = this.vertexList.indexOf(vertexLabel);
    if (removeeIndex == -1) {
      return -1;
    }
    this.adjacencyMatrix.removeAt(removeeIndex);
    for (final row in this.adjacencyMatrix) {
      row.removeAt(removeeIndex);
    }
    vertexList.removeAt(removeeIndex);
    return 0;
  }

  // Method to remove an edge from the graph identified by its source and destination.
  // Does not do anything if the edge or, any or both of its terminal vertices are not present.
  // If the edge is really present, and removed, function returns 0, else -1.
  int removeEdge(vLType from, vLType to) {
    int fromIndex = this.vertexList.indexOf(from), toIndex = this.vertexList.indexOf(to);
    if (fromIndex == -1 || toIndex == -1) {
      return -1;
    }
    this.adjacencyMatrix[fromIndex][toIndex] = null;
    return 0;
  }

  // Method to get neighbours of the given vertex.
  // If vertex is not present, returns an empty list.
  List<vLType> getNeighbours(vLType vertex) {
    int fromIndex = this.vertexList.indexOf(vertex);
    List<vLType> result = [];
    if (fromIndex != -1) {
      for (int i = 0, end = this.vertexList.length; i < end; i++) {
        if (this.adjacencyMatrix[fromIndex][i] != null) {
          result.add(this.vertexList[i]);
        }
      }
    }
    return result;
  }

  // Conversion to string
  @override String toString() {
    String result = "Vertices: $vertexList\n";
    result += "Edges are:\n";
    for (int i = 0, end = vertexList.length; i < end; i++) {
      for (int j = 0; j < end; j++) {
        if (adjacencyMatrix[i][j] != null) {
          result += "From ${vertexList[i]} to ${vertexList[j]} weighted ${adjacencyMatrix[i][j]}\n";
        }
      }
    }
    return result;
  }
}