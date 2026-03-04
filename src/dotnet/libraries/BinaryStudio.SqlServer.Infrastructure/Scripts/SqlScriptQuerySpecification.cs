using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptQuerySpecification : SqlScriptQueryExpression<SqlQuerySpecification>
        {
        #region ctor{IServiceProvider,SqlQuerySpecification}
        public SqlScriptQuerySpecification(IServiceProvider context,SqlQuerySpecification source)
            : base(context,source)
            {
            }
        #endregion
        }
    }