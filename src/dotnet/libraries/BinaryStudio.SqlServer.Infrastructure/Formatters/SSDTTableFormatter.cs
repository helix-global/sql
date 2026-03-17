using BinaryStudio.SqlServer.Infrastructure.Formatters;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SSDTTableFormatter : SqlObjectFormatter<ISqlTable>
        {
        public static readonly ISqlObjectFormatter<ISqlTable> Instance = new SSDTTableFormatter();

        #region M:WriteTo(T,TextWriter)
        public override void WriteTo(ISqlTable source,TextWriter target) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            if (target == null) { throw new ArgumentNullException(nameof(target)); }
            target.WriteLine($"CREATE TABLE {source.QualifiedName} (");
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
                typvl[j] = column.IsComputed ? "AS" : column.TypeSpecifier.ToString(SSDTTypeSpecifierFormatter.Instance);
                nulvl[j] = column.IsComputed
                    ? $" {((ISqlComputedColumn)column).Expression}"
                    : column.Constraints.Any(i => i.Type == SqlConstraintType.NotNull) ? " NOT NULL" : " NULL";

                var identity = column.Constraints.FirstOrDefault(i => i.Type == SqlConstraintType.Identity);
                idevl[j] = (identity != null)? $" {identity.ToString(SSDTConstraintFormatter.Instance)}" : String.Empty;

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

            #region PRIMARY KEY
            foreach (var constraint in source.Constraints.OfType<ISqlScriptUniqueConstraint>().Where(i=>i.Type == SqlConstraintType.PrimaryKey)) {
                var r = new StringBuilder();
                if (constraint.Name != null)
                    {
                    r.Append($"CONSTRAINT [{constraint.Name}] ");
                    }
                r.Append($"PRIMARY KEY");
                r.Append(IsClustered(constraint.ClusterOption) ? " CLUSTERED" : " NONCLUSTERED");
                r.Append(" (");
                r.Append(String.Join(", ",constraint.IndexedColumns.Select(i => $"[{i.Name}] {(i.SortOrder == SqlSortOrder.Descending ? "DESC":"ASC")}")));
                r.Append(")");
                if (constraint.IndexOptions.Any()) {
                    r.Append(" WITH");
                    foreach (var option in constraint.IndexOptions) {
                        switch (option.Type) {
                            case SqlIndexOptionType.FillFactor: { r.Append($" (FILLFACTOR = {((ISqlFillFactorIndexOption)option).FillFactor})"); } break;
                            default: throw new NotSupportedException();
                            }
                        }
                    }
                colvl.Add(r.ToString());
                }
            #endregion
            #region FOREIGN KEY
            foreach (var constraint in source.Constraints.OfType<ISqlForeignKeyConstraint>()) {
                var r = new StringBuilder();
                r.Append($"CONSTRAINT [{constraint.Name}] FOREIGN KEY");
                r.Append(" (");
                r.Append(String.Join(", ",constraint.Columns.Select(i => $"[{i}]")));
                r.Append($") REFERENCES {constraint.ReferencedTable} (");
                r.Append(String.Join(", ",constraint.ReferencedColumns.Select(i => $"[{i}]")));
                r.Append(")");
                if (constraint.DeleteAction != SqlForeignKeyAction.NoAction) {
                    r.Append(" ON DELETE ");
                    switch (constraint.DeleteAction) {
                        case SqlForeignKeyAction.Cascade   : { r.Append("CASCADE");     } break;
                        case SqlForeignKeyAction.SetNull   : { r.Append("SET NULL");    } break;
                        case SqlForeignKeyAction.SetDefault: { r.Append("SET DEFAULT"); } break;
                        default: throw new ArgumentOutOfRangeException();
                        }
                    }
                colvl.Add(r.ToString());
                }
            #endregion

            namsz = colvl.Count - 1;
            typsz = source.Columns.Count;

            j = 0;
            foreach (var col in colvl) {
                target.Write("    ");
                target.Write(col);
                target.Write((j == namsz) ? "" : ",");
                target.WriteLine();
                j++;
                }
            target.WriteLine(");");
            target.WriteLine();
            }
        #endregion
        #region M:IsClustered(SqlClusterOption):Boolean
        private static Boolean IsClustered(SqlClusterOption value) {
            return (value == SqlClusterOption.Clustered)
                || (value == SqlClusterOption.ClusteredColumnStore);
            }
        #endregion
        }
    }