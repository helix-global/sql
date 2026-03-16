using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    internal abstract class SqlScriptModuleOption<T> : SqlScriptCodeObject<T>
        where T : SqlModuleOption
        {
        public SqlModuleOptionType Type { get { return Source.Type; }}

        #region ctor{IServiceProvider,T}
        protected SqlScriptModuleOption(IServiceProvider context,T source)
            : base(context,source)
            {
            }
        #endregion

        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Type.ToString();
            }
        #endregion
        }
    }