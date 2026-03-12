using System;
using JetBrains.Annotations;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlFragmentAlterTableStatement<T> : SqlFragmentObject<T>,ISqlScriptStatement
        where T : AlterTableStatement
        {
        public String StatementPhrase { get { return "ALTER TABLE"; }}
        [UsedImplicitly][Field(Source="SchemaObjectName")] public SqlObjectIdentifier Name { get; }

        #region ctor{IServiceProvider,T}
        protected SqlFragmentAlterTableStatement(IServiceProvider context,T source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }
    }