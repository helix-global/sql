using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(CreateAggregateStatement))]
    internal class SqlFragmentCreateAggregateStatement : SqlFragmentObject<CreateAggregateStatement>,ISqlScriptStatement
        {
        public String StatementPhrase { get { return "CREATE AGGREGATE"; }}

        #region ctor{IServiceProvider,CreateAggregateStatement}
        public SqlFragmentCreateAggregateStatement(IServiceProvider context,CreateAggregateStatement source)
            : base(context,source)
            {
            }
        #endregion
        }
    }