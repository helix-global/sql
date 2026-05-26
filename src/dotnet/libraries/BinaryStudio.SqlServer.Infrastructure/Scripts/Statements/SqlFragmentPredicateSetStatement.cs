using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [SqlScriptObject(typeof(PredicateSetStatement))]
    internal class SqlFragmentPredicateSetStatement : SqlFragmentSetOnOffStatement<PredicateSetStatement>
        {
        [UsedImplicitly][Field] public SetOptions Options { get; }

        #region ctor{IServiceProvider,PredicateSetStatement}
        public SqlFragmentPredicateSetStatement(IServiceProvider context,PredicateSetStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }