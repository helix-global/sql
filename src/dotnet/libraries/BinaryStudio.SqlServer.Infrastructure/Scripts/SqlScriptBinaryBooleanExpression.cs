using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlBinaryBooleanExpression))]
    internal sealed class SqlScriptBinaryBooleanExpression : SqlScriptBooleanExpression<SqlBinaryBooleanExpression>
        {
        #region ctor{IServiceProvider,SqlBinaryBooleanExpression}
        public SqlScriptBinaryBooleanExpression(IServiceProvider context,SqlBinaryBooleanExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }