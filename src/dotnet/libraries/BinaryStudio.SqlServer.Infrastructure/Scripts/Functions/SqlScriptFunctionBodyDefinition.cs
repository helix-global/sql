using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptFunctionBodyDefinition<T> : SqlScriptCodeObject<T>
        where T: SqlFunctionBodyDefinition
        {
        #region ctor{IServiceProvider,T}
        protected SqlScriptFunctionBodyDefinition(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion
        }
    }