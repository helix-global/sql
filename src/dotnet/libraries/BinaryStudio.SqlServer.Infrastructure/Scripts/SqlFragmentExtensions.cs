using System.Collections.Generic;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal static class SqlScriptDomExtensions
        {
        #region M:Descendants<T>({this}TSqlFragment):IEnumerable<T>
        public static IEnumerable<T> Descendants<T>(this TSqlFragment source) {
            if (source != null) {
                if (source is TSqlScript TSqlScript) { return Descendants<T>(TSqlScript); }
                if (source is TSqlBatch  TSqlBatch ) { return Descendants<T>(TSqlBatch);  }
                }
            return EmptyArray<T>.Array;
            }
        #endregion
        #region M:Descendants<T>(TSqlScript):IEnumerable<T>
        private static IEnumerable<T> Descendants<T>(TSqlScript source) {
            foreach (var i in source.Batches) {
                if (i is T o) { yield return o; }
                foreach (var j in Descendants<T>(i)) {
                    yield return j;
                    }
                }
            }
        #endregion
        #region M:Descendants<T>(TSqlBatch):IEnumerable<T>
        private static IEnumerable<T> Descendants<T>(TSqlBatch source) {
            foreach (var i in source.Statements) {
                if (i is T o) { yield return o; }
                foreach (var j in Descendants<T>(i)) {
                    yield return j;
                    }
                }
            }
        #endregion
        }
    }