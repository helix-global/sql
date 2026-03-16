using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlNotBooleanExpression))]
    internal sealed class SqlScriptNotBooleanExpression : SqlScriptBooleanExpression<SqlNotBooleanExpression>
        {
        #region ctor{IServiceProvider,SqlNotBooleanExpression}
        public SqlScriptNotBooleanExpression(IServiceProvider context,SqlNotBooleanExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }