using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlTableFormatter : SqlObjectFormatter<ISqlTable>
        {
        #region M:WriteTo(T,TextWriter)
        public override void WriteTo(ISqlTable source,TextWriter target) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            if (target == null) { throw new ArgumentNullException(nameof(target)); }
            target.WriteLine($"create table {source.QualifiedName} (");
            var namvl = new String[source.Columns.Count];
            var typvl = new String[namvl.Length];
            var nulvl = new String[namvl.Length];
            var idevl = new String[namvl.Length];
            var colvl = new List<String>();
            var namsz = 0;
            var typsz = 0;
            var nulsz = 0;
            var idesz = 0;
            var j = 0;
            foreach (var column in source.Columns) {
                namvl[j] = $"[{column.Name}]";
                typvl[j] = $"{FormatDataType(column)}";
                nulvl[j] = column.IsComputed ? String.Empty : column.Constraints.Any(i => i.Type == SqlConstraintType.NotNull) ? " not null" : " null";

                var identity = column.Constraints.FirstOrDefault(i => i.Type == SqlConstraintType.Identity);
                idevl[j] = (identity != null)? $" {identity}" : String.Empty;

                namsz = Math.Max(namsz,namvl[j].Length);
                typsz = Math.Max(typsz,typvl[j].Length);
                nulsz = Math.Max(nulsz,nulvl[j].Length);
                idesz = Math.Max(idesz,idevl[j].Length);
                j++;
                }
            for (j=0;j < namvl.Length;j++) {
                colvl.Add(String.Format($"{{0,-{namsz}}} {{1,-{typsz}}}{{3}}{{2}}",
                    namvl[j],
                    typvl[j],
                    nulvl[j],
                    idevl[j]));
                }

            namsz = colvl.Count - 1;
            typsz = source.Columns.Count;

            j = 0;
            foreach (var col in colvl) {
                target.Write("  ");
                target.Write((j == 0) ? " " : ",");
                target.Write(col);
                if (j < typsz) {

                    }
                target.WriteLine();
                j++;
                }
            target.WriteLine("  )");
            }
        #endregion
        #region M:FormatDataType:String
        private static String FormatDataType(ISqlColumn column) {
            if (column.IsComputed && column is ISqlComputedColumn c) {
                return $"as {c.Expression}";
                }
            return column.TypeSpecifier.ToString();
            }
        #endregion
        }
    }