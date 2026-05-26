using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;
using JetBrains.Annotations;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [SqlScriptObject(typeof(SqlComputedColumnDefinition))]
    internal sealed class SqlScriptComputedColumnDefinition : SqlScriptColumnDefinition<SqlComputedColumnDefinition>,ISqlComputedColumn
        {
        public override Boolean IsComputed { get { return true; }}
        [UsedImplicitly][Field] public Boolean IsPersisted { get; }
        [UsedImplicitly][Field] public ISqlScriptScalarExpression Expression { get; }
        String ISqlComputedColumn.Expression { get { return Expression.ToString(); }}

        #region ctor{IServiceProvider,SqlComputedColumnDefinition}
        public SqlScriptComputedColumnDefinition(IServiceProvider context,SqlComputedColumnDefinition source)
            : base(context,source)
            {
            return;
            }
        #endregion
        }
    }