//#define TEST_CASE_1
#define TEST_CASE_2
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using static BinaryStudio.SqlServer.Infrastructure.SqlIdentifier;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SSDTTableFormatter : SqlObjectFormatter<ISqlTable>
        {
        public static readonly ISqlObjectFormatter<ISqlTable> Instance = new SSDTTableFormatter();
        public Boolean IgnorePrimaryKeySystemName { get;set; }
        public Boolean IgnorePrimaryKeyOptions { get;set; }
        public Boolean IgnoreDefaultConstraintSystemName { get;set; }

        #region M:WriteTo(IServiceProvider,T,TextWriter)
        public override void WriteTo(IServiceProvider provider,ISqlTable source,TextWriter target) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            if (target == null) { throw new ArgumentNullException(nameof(target)); }
            var PropertyProvider = (ISqlExtendedPropertyResolver)provider?.GetService(typeof(ISqlExtendedPropertyResolver));
            target.WriteLine($"CREATE TABLE {source.QualifiedName} (");
            var namvl = new String[source.Columns.Count];
            var typvl = new String[namvl.Length];
            var nulvl = new String[namvl.Length];
            var idevl = new String[namvl.Length];
            var colvl = new List<String>();
            var extpr = new List<String>();
            var namsz = 0;
            var typsz = 0;
            var nulsz = 0;
            var idesz = 0;
            var j = 0;
            foreach (var column in source.Columns) {
                namvl[j] = $"[{column.Name}]";
                typvl[j] = column.IsComputed ? "AS" : column.TypeSpecifier.ToString(SSDTTypeSpecifierFormatter.Instance);
                if (column.IsComputed)
                    {
                    nulvl[j] = $" {((ISqlComputedColumn)column).Expression}";
                    }
                else
                    {
                    var r = new StringBuilder();
                    foreach (var constraint in column.Constraints) {
                        switch (constraint.Type) {
                            case SqlConstraintType.NotNull : { r.Append(" NOT NULL");} break;
                            case SqlConstraintType.Null    : { r.Append(" NULL");    } break;
                            case SqlConstraintType.Identity: break;
                            case SqlConstraintType.Default:
                                {
                                var ConstraintName = constraint.Name?.ToString();
                                if (ConstraintName != null) {
                                    if (IgnoreDefaultConstraintSystemName) {
                                        if (IsMatch(ConstraintName, "^DF__.+_[A-F0-9]+$")) {
                                            ConstraintName = null;
                                            }
                                        }
                                    }
                                if (!String.IsNullOrWhiteSpace(ConstraintName)) {
                                    r.Append($" CONSTRAINT [{ConstraintName}]");
                                    }
                                r.Append($" DEFAULT {((ISqlDefaultConstraint)constraint).Expression}");
                                }
                                break;
                            default: throw new NotSupportedException();
                            }
                        }
                    nulvl[j] = r.ToString();
                    }

                if (PropertyProvider != null) {
                    var prop = PropertyProvider.GetObject(new SqlExtendedPropertyIdentity(SqlObjectClass.Column,column.QualifiedName,"MS_Description"));
                    if (prop != null) {
                        extpr.Add($"EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'{FormatLiteral(prop)}', @level0type = N'SCHEMA', @level0name = N'{source.QualifiedName.SchemaName}', @level1type = N'TABLE', @level1name = N'{source.QualifiedName.ObjectName}', @level2type = N'COLUMN', @level2name = N'{column.Name}'");
                        }
                    }

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

            if (PropertyProvider != null) {
                var prop = PropertyProvider.GetObject(new SqlExtendedPropertyIdentity(SqlObjectClass.Table,source.QualifiedName,"MS_Description"));
                if (prop != null) {
                    extpr.Add($"EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'{FormatLiteral(prop)}', @level0type = N'SCHEMA', @level0name = N'{source.QualifiedName.SchemaName}', @level1type = N'TABLE', @level1name = N'{source.QualifiedName.ObjectName}'");
                    }
                }

            #region PRIMARY KEY
            foreach (var constraint in source.Constraints.OfType<ISqlScriptUniqueConstraint>().Where(i=>i.Type == SqlConstraintType.PrimaryKey)) {
                var r = new StringBuilder();
                var ConstraintName = constraint.Name?.ToString();
                if (IgnorePrimaryKeySystemName) {
                    if (ConstraintName != null) {
                        if (ConstraintName.StartsWith(source.QualifiedName.ToString())) {
                            ConstraintName = null;
                            }
                        else if (IsMatch(ConstraintName, "^PK__.+_[A-F0-9]+$"))
                            {
                            ConstraintName = null;
                            }
                        }
                    }
                if (!String.IsNullOrEmpty(ConstraintName))
                    {
                    r.Append($"CONSTRAINT [{ConstraintName}] ");
                    }
                r.Append($"PRIMARY KEY");
                r.Append(IsClustered(constraint.ClusterOption) ? " CLUSTERED" : " NONCLUSTERED");
                r.Append(" (");
                r.Append(String.Join(", ",constraint.IndexedColumns.Select(i => $"[{i.Name}] {(i.SortOrder == SqlSortOrder.Descending ? "DESC":"ASC")}")));
                r.Append(")");
                if (!IgnorePrimaryKeyOptions && constraint.IndexOptions.Any()) {
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
            #region CHECK CONSTRAINT
            foreach (var constraint in source.Constraints.OfType<ISqlCheckConstraint>().Where(i=>i.Type == SqlConstraintType.Check)) {
                var r = new StringBuilder();
                if (constraint.Name != Null)
                    {
                    r.Append($"CONSTRAINT [{constraint.Name}] ");
                    }
                r.Append($"CHECK");
                r.Append($" ({constraint.Expression})");
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
                if (constraint.UpdateAction != SqlForeignKeyAction.NoAction) {
                    r.Append(" ON UPDATE ");
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
            #region UNIQUE CONSTRAINT
            foreach (var constraint in source.Constraints.OfType<ISqlScriptUniqueConstraint>().Where(i=>i.Type == SqlConstraintType.Unique)) {
                var r = new StringBuilder();
                if (constraint.Name != Null)
                    {
                    r.Append($"CONSTRAINT [{constraint.Name}] ");
                    }
                r.Append($"UNIQUE");
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

            #region CREATE INDEX
            foreach (var index in source.Indexes.OrderByDescending(i=>i.Name)) {
                if (source.Constraints.Any(i => SqlIdentifier.Equals(i.Name,index.Name))) { continue; }
                target.WriteLine();
                target.WriteLine("GO");
                target.Write("CREATE");
                if (index.IsUnique)
                    {
                    target.Write(" UNIQUE");
                    }
                target.Write(IsClustered(index.ClusterOption) ? " CLUSTERED" : " NONCLUSTERED");
                target.WriteLine($" INDEX [{index.Name}]");
                target.Write($"    ON {index.TargetObject}(");
                target.Write(String.Join(", ",index.IndexedColumns.Select(i=> $"[{i.Name}] {(i.SortOrder == SqlSortOrder.Descending ? "DESC":"ASC")}")));
                target.Write(")");
                if (index.IncludedColumns.Any()) {
                    target.WriteLine();
                    target.Write("    INCLUDE(");
                    target.Write(String.Join(", ",index.IncludedColumns.Select(i=>$"[{i}]")));
                    target.Write(")");
                    }
                if (!String.IsNullOrWhiteSpace(index.FilterExpression)) {
                    target.Write($" WHERE ({index.FilterExpression})");
                    }
                if (index.Options.Any()) {
                    target.Write(" WITH");
                    foreach (var option in index.Options) {
                        switch (option.Type) {
                            case SqlIndexOptionType.FillFactor: { target.Write($" (FILLFACTOR = {((ISqlFillFactorIndexOption)option).FillFactor})"); } break;
                            default: throw new NotSupportedException();
                            }
                        }
                    }
                target.WriteLine(";");
                target.WriteLine();

                if (PropertyProvider != null) {
                    var prop = PropertyProvider.GetObject(new SqlExtendedPropertyIdentity(SqlObjectClass.Index,index.QualifiedName,"MS_Description"));
                    if (prop != null) {
                        extpr.Add($"EXECUTE sp_addextendedproperty @name = N'MS_Description', @value = N'{FormatLiteral(prop)}', @level0type = N'SCHEMA', @level0name = N'{source.QualifiedName.SchemaName}', @level1type = N'TABLE', @level1name = N'{source.QualifiedName.ObjectName}', @level2type = N'INDEX', @level2name = N'{index.Name}'");
                        }
                    }
                }
            #endregion
            #region CREATE TRIGGER
            foreach (var trigger in source.Triggers) {
                target.WriteLine();
                target.WriteLine("GO");
                target.Write(((ISqlScriptCodeObject)trigger).Script);
                }
            #endregion

            foreach (var e in extpr) {
                target.WriteLine();
                target.WriteLine("GO");
                target.Write(e);
                target.WriteLine(";");
                target.WriteLine();
                }
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