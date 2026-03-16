using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlRowConstructorExpression))]
    internal sealed class SqlScriptRowConstructorExpression : SqlScriptCodeObject<SqlRowConstructorExpression>
        {
        #region ctor{IServiceProvider,SqlRowConstructorExpression}
        public SqlScriptRowConstructorExpression(IServiceProvider context,SqlRowConstructorExpression source)
            : base(context,source)
            {
            }
        #endregion
        }
    }