using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal sealed class SqlScriptInBooleanExpressionCollectionValue : SqlScriptInBooleanExpressionValue<SqlInBooleanExpressionCollectionValue>
        {
        #region ctor{IServiceProvider,SqlInBooleanExpressionCollectionValue}
        public SqlScriptInBooleanExpressionCollectionValue(IServiceProvider context,SqlInBooleanExpressionCollectionValue source)
            : base(context,source)
            {
            }
        #endregion
        }
    }