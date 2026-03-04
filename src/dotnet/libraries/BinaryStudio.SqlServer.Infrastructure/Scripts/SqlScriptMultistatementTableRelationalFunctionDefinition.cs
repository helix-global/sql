using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlScriptMultistatementTableRelationalFunctionDefinition : SqlScriptFunctionDefinition<SqlMultistatementTableRelationalFunctionDefinition>
        {
        public String VariableName { get { return Source.VariableName; }}
        public SqlScriptMultistatementFunctionBodyDefinition BodyDefinition { get; }

        #region ctor{IServiceProvider,SqlMultistatementTableRelationalFunctionDefinition}
        public SqlScriptMultistatementTableRelationalFunctionDefinition(IServiceProvider context,SqlMultistatementTableRelationalFunctionDefinition source)
            : base(context,source)
            {
            }
        #endregion
        }
    }