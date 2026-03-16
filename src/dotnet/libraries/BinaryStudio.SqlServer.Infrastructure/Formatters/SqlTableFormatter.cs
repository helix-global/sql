using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlTableFormatter : SqlObjectFormatter<ISqlTable>
        {
        public ISqlCase Case { get; }

        #region ctor
        public SqlTableFormatter()
            :this(SqlCase.Uppercase)
            {
            }
        #endregion
        #region ctor{Boolean}
        public SqlTableFormatter(ISqlCase Case)
            {
            this.Case = Case;
            }
        #endregion

        #region M:WriteTo(T,TextWriter)
        public override void WriteTo(ISqlTable source,TextWriter target) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            if (target == null) { throw new ArgumentNullException(nameof(target)); }
            target.WriteLine($"{ChangeCase("create table")} {source.QualifiedName} (");
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
                nulvl[j] = column.IsComputed ? String.Empty : column.Constraints.Any(i => i.Type == SqlConstraintType.NotNull) ? ChangeCase(" not null") : ChangeCase(" null");

                var identity = column.Constraints.FirstOrDefault(i => i.Type == SqlConstraintType.Identity);
                idevl[j] = (identity != null)? $" {identity.ToString(Case)}" : String.Empty;

                namsz = Math.Max(namsz,namvl[j].Length);
                typsz = Math.Max(typsz,column.IsComputed ? 0 : typvl[j].Length);
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
        private String FormatDataType(ISqlColumn column) {
            if (column.IsComputed && column is ISqlComputedColumn c) {
                return $"{ChangeCase("as")} {c.Expression}";
                }
            return column.TypeSpecifier.ToString(Case);
            }
        #endregion
        #region M:ChangeCase:String
        private String ChangeCase(String value) {
            return Case.ChangeCase(value);
            }
        #endregion
        }
    }